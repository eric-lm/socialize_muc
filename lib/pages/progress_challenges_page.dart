import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../app/app_active_user.dart';
import 'dart:math' show min;
import 'package:cloud_functions/cloud_functions.dart' as functions;

class ProgressChallengesPage extends StatelessWidget {
  final List<Challenge> challenges;

  const ProgressChallengesPage({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    final sortedChallenges = List<Challenge>.from(challenges)
      ..sort((a, b) {
        // First compare by type
        int typeComparison = a.type.index.compareTo(b.type.index);
        if (typeComparison != 0) return typeComparison;

        // Then compare by level (where level is an integer)
        // If level is null, treat it as highest level (put at end)
        final levelA = a.level ?? 999;
        final levelB = b.level ?? 999;
        return levelA.compareTo(levelB);
      });

    // Filter only progress challenges
    final progressChallenges =
        sortedChallenges.where((c) => c.type == Type.PROGRESS).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Challenges'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Your Social Journey',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildChallengeTimeline(context, progressChallenges),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeTimeline(
      BuildContext context, List<Challenge> challenges) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChallengeCard(challenge),
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<double> _getChallengeProgress(String challengeId) async {
    try {
      print("hello");
      final userId = AppActiveUser.instance.userId;
      if (userId == null) return 0.0;

      final docRef = FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('private')
          .doc("progress");

      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) return 0.0;

      // Get the array of challenges
      final List<dynamic> challengeProgress =
          doc.data()?['challenge_progress'] ?? [];

      // Find the matching challenge
      final matchingProgress = challengeProgress.firstWhere(
        (progress) =>
            (progress['challenge'] as DocumentReference).id == challengeId,
        orElse: () => null,
      );

      if (matchingProgress == null) return 0.0;

      // Get progress value and convert to double
      final progress = matchingProgress['progress'] as num?;
      return (progress ?? 0).toDouble(); // Explicit conversion to double
    } catch (e) {
      print('ERROR: Error fetching progress: $e');
      return 0.0;
    }
  }

  Future<bool> _updateChallengeProgressFunction(
      String challengeId, double progress) async {
    try {
      // Debug print before call
      print('Attempting to call userChallengeUpdate with:');
      print('challengeId: $challengeId');
      print('progress: $progress');

      // Verify user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        print('ERROR: User not authenticated');
        return false;
      }

      final callable = functions.FirebaseFunctions.instance
          .httpsCallable('userChallengeUpdate');

      final result = await callable.call({
        'challengeId': challengeId,
        'progress': progress.toString(),
      });

      // Debug print response
      print('Function response: ${result.data}');

      final response = result.data as Map<String, dynamic>;
      if (response['Error'] != '') {
        print('ERROR from function: ${response['Error']}');
      }
      return response['WasCompleted'] as bool;
    } catch (e) {
      print('ERROR: Failed to call userChallengeUpdate: $e');
      // Print full stack trace
      print(StackTrace.current);
      return false;
    }
  }

  Future<void> _incrementChallengeProgress(
      String challengeId, Challenge challenge) async {
    try {
      double currentProgress = await _getChallengeProgress(challengeId);
      print('maxProgress: ${challenge.maxProgress}');
      if (currentProgress >= challenge.maxProgress) return;

      double newProgress = min((currentProgress + 1), 1.0);
      final success =
          await _updateChallengeProgressFunction(challengeId, newProgress);

      if (!success) {
        print('ERROR: Failed to update challenge progress');
      } else {
        print('Successfully updated challenge progress');
      }
    } catch (e) {
      print('ERROR: Error incrementing progress: $e');
    }
  }

  Future<void> _setChallengeProgress(
      String challengeId, double progress) async {
    try {
      final success =
          await _updateChallengeProgressFunction(challengeId, progress);
      if (!success) {
        print('ERROR: Failed to set challenge progress');
      }
    } catch (e) {
      print('ERROR: Error setting progress: $e');
    }
  }

  Widget _buildChallengeCard(Challenge challenge) {
    Color iconColor = challenge.type == Type.WEEKLY
        ? Colors.blue
        : challenge.type == Type.MONTHLY
            ? Colors.green
            : Colors.amber;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              iconColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getChallengeTypeIcon(challenge.type),
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.add,
                        color: iconColor,
                        size: 24,
                      ),
                      onPressed: () =>
                          _incrementChallengeProgress(challenge.id, challenge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.text),
              const SizedBox(height: 16),
              FutureBuilder<double>(
                future: _getChallengeProgress(challenge.id),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: snapshot.data ?? 0.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${((snapshot.data ?? 0.0) * 100).toInt()}% Complete',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getChallengeTypeIcon(Type type) {
    switch (type) {
      case Type.WEEKLY:
        return Icons.event;
      case Type.MONTHLY:
        return Icons.calendar_month;
      case Type.PROGRESS:
        return Icons.trending_up;
    }
  }
}
