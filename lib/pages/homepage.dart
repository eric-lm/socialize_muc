import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/models/challenge.dart';
import 'package:socialize/models/event.dart';
import 'package:socialize/widgets/event_preview_card.dart';
import 'package:socialize/widgets/challenge_preview_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.challenges});

  //final List<Event> events;
  final List<Challenge> challenges;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
    listenToChangeOfCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  listenToChangeOfCategories() {
    final collection = FirebaseFirestore.instance.collection('event');
    final listener = collection.snapshots().listen((change) {
      if (change.docChanges.isNotEmpty) {
        return _refreshEvents();
      }
    });
    listener.onDone(() {
      listener.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder(
                      future: _eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text("No events found"));
                        } else {
                          return EventPreviewCard(
                            events: snapshot.data!,
                            width: constraints.maxWidth,
                            height: 130,
                          );
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChallengePreviewCard(
                    challenges: widget.challenges,
                    width: constraints.maxWidth,
                    height: 200,
                    progressTrue: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChallengePreviewCard(
                    challenges: widget.challenges,
                    width: constraints.maxWidth,
                    height: 200,
                    progressTrue: false,
                  ),
                ),
                // Add other widgets here
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Event>> _loadEvents() async {
    try {
      var eventSnapshot =
          await FirebaseFirestore.instance.collection('event').get();
      List<Event> events = eventSnapshot.docs
          .map((doc) => Event.fromFirestore(doc, null))
          .toList();
      await removeUnassignedEvents(events);

      return events;
    } catch (e) {
      print("Error loading events: $e");
      return List.empty();
    }
  }
}

Future<List<Event>> removeUnassignedEvents(List<Event> ev) async {
  // Create a list of Future<bool> values, one for each event
  List<Future<bool>> assignmentChecks = ev.map((e) async {
    return await isUserAssigned(e, FirebaseAuth.instance.currentUser!);
  }).toList();

  // Wait for all the async operations to complete
  List<bool> results = await Future.wait(assignmentChecks);

  ev.removeWhere((event) {
    int index = ev.indexOf(event);
    return !results[index];
  });
  return ev;
}

Future<bool> isUserAssigned(Event event, User user) async {
  DocumentReference eventRef =
      FirebaseFirestore.instance.collection("event").doc(event.id);
  DocumentReference userRef =
      FirebaseFirestore.instance.collection('user').doc(user.uid);

  final querySnapshot = await FirebaseFirestore.instance
      .collection('event_participation')
      .where('user', isEqualTo: userRef)
      .get();

  Set<String> assignedEvents = await querySnapshot.docs
      .map((doc) => (doc.get('event') as DocumentReference).id)
      .toSet();
  return assignedEvents.contains(eventRef.id);
}
