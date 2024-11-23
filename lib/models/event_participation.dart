import 'package:cloud_firestore/cloud_firestore.dart';

class EventParticipation {
  final DocumentReference user;
  final DocumentReference event;
  final bool wasVerified;

  EventParticipation({
    required this.user,
    required this.event,
    required this.wasVerified,
  });

  factory EventParticipation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return EventParticipation(
      user: data?['user'],
      event: data?['event'],
      wasVerified: data?['was_verified'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': user,
      'event': event,
      'was_verified': wasVerified,
    };
  }
}
