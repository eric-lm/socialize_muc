import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime time;
  final String place;
  final DocumentReference organizer;
  final int numParticipants;
  final int maxParticipants;
  final String description;
  final List<String> tags;

  Event({
    required this.id,
    required this.title,
    required this.time,
    required this.place,
    required this.organizer,
    required this.numParticipants,
    required this.maxParticipants,
    required this.description,
    required this.tags,
  });

  factory Event.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Event(
      id: snapshot.id,
      title: data?['title'],
      time: (data?['time'] as Timestamp).toDate(),
      place: data?['place'],
      organizer: data?['organizer'],
      numParticipants: data?['num_participants'] ?? 0,
      maxParticipants: data?['max_participants'] ?? 0,
      description: data?['description'],
      tags: List<String>.from(data?['tags']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'time': Timestamp.fromDate(time),
      'place': place,
      'organizer': organizer,
      'max_participants': maxParticipants,
      'description': description,
      'tags': tags,
    };
  }
}
