import 'package:cloud_firestore/cloud_firestore.dart';
import 'challenge.dart';

enum Achievement {
  FIRST_EVENT,
  SOCIAL_BUTTERFLY,
  CHALLENGE_MASTER,
}

class User {
  final String id;
  final String displayName;
  final List<Achievement> achievements;
  final int level;
  final List<ChallengeProgress> challengeProgress;

  User({
    required this.id,
    required this.displayName,
    required this.achievements,
    required this.level,
    List<ChallengeProgress>? challengeProgress,
  }) : challengeProgress = challengeProgress ?? [];

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? {};

    // Handle achievements list
    List<Achievement> achievements = [];
    try {
      final achievementsList = data['achievements'] as List?;
      if (achievementsList != null) {
        achievements = achievementsList
            .map((e) => Achievement.values.byName(e.toString()))
            .toList();
      }
    } catch (e) {
      print('Error parsing achievements: $e');
    }

    // Handle challenge progress list
    List<ChallengeProgress> progress = [];
    try {
      final progressList = data['challenge_progress'] as List?;
      if (progressList != null) {
        progress = progressList.map((item) {
          final challengeRef = item['challenge'] as DocumentReference?;
          return ChallengeProgress(
            challenge: Challenge(
              id: challengeRef?.id ?? '',
              title: 'Loading...', // These will be updated when challenge loads
              text: '',
              maxProgress: 0,
              isUserCompletable: true,
              type: ChallengeType.WEEKLY,
            ),
            progress: item['progress'] ?? 0,
            currentStreak: item['current_streak'] ?? 0,
          );
        }).toList();
      }
    } catch (e) {
      print('Error parsing challenge progress: $e');
    }

    return User(
      id: snapshot.id,
      displayName: data['display_name'] ?? 'Unknown User',
      achievements: achievements,
      level: (data['level'] ?? 1).toInt(),
      challengeProgress: progress,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'display_name': displayName,
      'achievements': achievements.map((e) => e.name).toList(),
      'level': level,
      'challenge_progress': challengeProgress
          .map((e) => {
                'challenge': FirebaseFirestore.instance
                    .collection('challenge')
                    .doc(e.challenge.id),
                'progress': e.progress,
                'current_streak': e.currentStreak,
              })
          .toList(),
    };
  }
}

// Update ChallengeProgress to match schema
class ChallengeProgress {
  final Challenge challenge;
  final int progress;
  final int currentStreak;

  ChallengeProgress({
    required this.challenge,
    required this.progress,
    required this.currentStreak,
  });
}
