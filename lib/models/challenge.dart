import 'package:cloud_firestore/cloud_firestore.dart';

enum Type { WEEKLY, MONTHLY, PROGRESS }

class Challenge {
  final String id;
  final String title;
  final String text;
  final int maxProgress;
  final bool isUserCompletable;
  final Type type;
  final int? level;

  Challenge({
    required this.id,
    required this.title,
    required this.text,
    required this.maxProgress,
    required this.isUserCompletable,
    required this.type,
    this.level,
  }) {}

  factory Challenge.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    try {
      final data = snapshot.data();

      if (data == null) {
        print('Error: Document data is null for ${snapshot.id}');
        throw Exception('Document data is null');
      }

      return Challenge(
        id: snapshot.id,
        title: data['title'] ?? 'Untitled Challenge',
        text: data['text'] ?? 'No description',
        maxProgress: data['max_progress'] ?? 0,
        isUserCompletable: data['is_user_completable'] ?? false,
        type: Type.values.byName(data['type'] ?? 'WEEKLY'),
        level: data['level'],
      );
    } catch (e) {
      print('Error creating Challenge from Firestore: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'text': text,
      'max_progress': maxProgress,
      'is_user_completable': isUserCompletable,
      'type': type.name,
      if (level != null) 'level': level,
    };
  }

  @override
  String toString() {
    return 'Challenge{id: $id, title: $title, type: $type, level: $level}';
  }
}

class ChallengeProgress {
  final Challenge challenge;
  final int progress;
  final int currentStreak;

  ChallengeProgress({
    required this.challenge,
    required this.progress,
    required this.currentStreak,
  });

  factory ChallengeProgress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ChallengeProgress(
      challenge: data?['challenge'],
      progress: data?['progress'],
      currentStreak: data?['current_streak'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challenge': challenge,
      'progress': progress,
      'current_streak': currentStreak,
    };
  }
}
