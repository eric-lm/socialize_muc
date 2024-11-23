import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime time;
  final GeoPoint place;
  final DocumentReference organizer;
  final int numParticipants;
  final int minNumParticipants;
  final String description;
  final List<String> tags;

  Event({
    required this.id,
    required this.title,
    required this.time,
    required this.place,
    required this.organizer,
    required this.numParticipants,
    required this.minNumParticipants,
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
      minNumParticipants: data?['min_num_participants'] ?? 0,
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
      'num_participants': numParticipants,
      'min_num_participants': minNumParticipants,
      'description': description,
      'tags': tags,
    };
  }
}
