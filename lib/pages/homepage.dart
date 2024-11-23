import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'progress_challenges_page.dart';
import '../models/event.dart';
import '../models/challenge.dart';
import '../models/user.dart' as user_model;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print('HomePage initialized');
    getEvents().listen(
      (events) => print('Events received: ${events.length}'),
      onError: (error) => print('Error fetching events: $error'),
    );
    getChallenges().listen(
      (challenges) => print('Challenges received: ${challenges.length}'),
      onError: (error) => print('Error fetching challenges: $error'),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Stream<List<Event>> getEvents() {
    return db.collection('event').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc, null))
          .toList();
    });
  }

  Stream<List<Challenge>> getChallenges() {
    return db.collection('challenge').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Challenge.fromFirestore(doc, null))
          .toList();
    });
  }

  Future<Challenge?> getChallengeById(String challengeId) async {
    try {
      print('Fetching challenge with ID: $challengeId');
      final docSnapshot =
          await db.collection('challenges').doc(challengeId).get();

      if (!docSnapshot.exists) {
        print('No challenge found with ID: $challengeId');
        return null;
      }

      print('Found challenge document, converting to Challenge object');
      return Challenge.fromFirestore(docSnapshot, null);
    } catch (e) {
      print('Error fetching challenge: $e');
      rethrow;
    }
  }

  Stream<user_model.User> getCurrentUser() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    return db.collection('user').doc(userId).snapshots().map((snapshot) {
      return user_model.User.fromFirestore(snapshot, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<user_model.User>(
      stream: getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          print('Error in user stream: ${userSnapshot.error}');
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Challenges Preview
                StreamBuilder<List<Challenge>>(
                  stream: getChallenges(),
                  builder: (context, challengeSnapshot) {
                    if (!challengeSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final progressChallenges = challengeSnapshot.data!
                        .where((c) => c.type == Type.PROGRESS)
                        .toList();
                    if (progressChallenges.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Challenges',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNextChallengePreview(progressChallenges.first),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),

                // Reoccurring Challenges Preview
                StreamBuilder<List<Challenge>>(
                  stream: getChallenges(),
                  builder: (context, challengeSnapshot) {
                    if (!challengeSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final reoccurringChallenges = challengeSnapshot.data!
                        .where((c) => c.type != Type.PROGRESS)
                        .toList();
                    if (reoccurringChallenges.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly & Monthly Challenges',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNextChallengePreview(
                              reoccurringChallenges.first),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),

                // Events Section (existing code)
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Event>>(
                  stream: getEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Text('Error loading events: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 380,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: snapshot.data!.length,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _buildEventCard(snapshot.data![index]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            snapshot.data!.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextChallengePreview(Challenge challenge) {
    Color iconColor = challenge.type == Type.WEEKLY
        ? Colors.blue
        : challenge.type == Type.MONTHLY
            ? Colors.green
            : Colors.amber;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(challenge.type),
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.text,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StreamBuilder<List<Challenge>>(
                      stream: getChallenges(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return ProgressChallengesPage(
                            challenges: snapshot.data!);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              color: Colors.blue,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(Type type) {
    switch (type) {
      case Type.WEEKLY:
        return Icons.calendar_today;
      case Type.MONTHLY:
        return Icons.event;
      case Type.PROGRESS:
        return Icons.trending_up;
    }
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.id,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.calendar_today, event.time.toString()),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, event.place),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.people, '${event.numParticipants} people attending'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'RSVP Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
