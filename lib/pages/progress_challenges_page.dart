import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../helper/pair.dart';
import '../models/challenge.dart';
import 'dart:math' show min;
import 'package:cloud_functions/cloud_functions.dart' as functions;

class ProgressChallengesPage extends StatelessWidget {
  final List<Pair<Challenge, int?>> challenges;

  const ProgressChallengesPage({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    final sortedChallenges = List<Pair<Challenge, int?>>.from(challenges)
      ..sort((a, b) {
        // First compare by type
        int typeComparison = a.a.type.index.compareTo(b.a.type.index);
        if (typeComparison != 0) return typeComparison;

        // Then compare by level (where level is an integer)
        // If level is null, treat it as highest level (put at end)
        final levelA = a.a.level ?? 999;
        final levelB = b.a.level ?? 999;
        return levelA.compareTo(levelB);
      });

    // Filter only progress challenges
    final progressChallenges =
        sortedChallenges.where((c) => c.a.type == ChallengeType.PROGRESS).toList();

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
      BuildContext context, List<Pair<Challenge, int?>> challenges) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return Row(
              children: [
                Expanded(
                  child: _buildChallengeCard(challenge),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<bool> _updateChallengeProgressFunction(
      String challengeId, int progress) async {
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
      var currentProgress = challenges.firstWhere((ch) => ch.a.id == challengeId).b ?? 0;
      print('maxProgress: ${challenge.maxProgress}');
      if (currentProgress >= challenge.maxProgress) return;

      var newProgress = min((currentProgress + 1), 1);
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

  Widget _buildChallengeCard(Pair<Challenge, int?> challenge) {
    Color iconColor = challenge.a.type == ChallengeType.WEEKLY
        ? Colors.blue
        : challenge.a.type == ChallengeType.MONTHLY
            ? Colors.green
            : Colors.amber;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              iconColor.withOpacity(0.4),
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
                      _getChallengeTypeIcon(challenge.a.type),
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.a.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (challenge.a.isUserCompletable && (challenge.b ?? 0) < challenge.a.maxProgress)
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
                          Icons.check_circle,
                          color: iconColor,
                          size: 24,
                        ),
                        onPressed: () =>
                            _incrementChallengeProgress(challenge.a.id, challenge.a),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.a.text),
              const SizedBox(height: 16),
              StepProgressIndicator(
                currentStep: challenge.b ?? 0,
                totalSteps: challenge.a.maxProgress,
                selectedColor: Colors.tealAccent,
                unselectedColor: Colors.grey,
                size: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.WEEKLY:
        return Icons.event;
      case ChallengeType.MONTHLY:
        return Icons.calendar_month;
      case ChallengeType.PROGRESS:
        return Icons.trending_up;
    }
  }
}
