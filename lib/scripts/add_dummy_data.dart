// lib/utils/dummy_data_initializer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class DummyDataInitializer {
  static Future<void> initializeDummyEvents() async {
    print('Adding dummy events to Firestore');
    try {
      final db = FirebaseFirestore.instance;
      final eventsCollection = db.collection('event');
      final existingEvents = await eventsCollection.get();

      final dummyEvents = [
        Event(
          id: 'event1',
          title: 'Dummy Event 1',
          time: DateTime.now(),
          place: 'Place 1',
          organizer: db.collection('user').doc('ehTPHh3iv2gXJ0R649p47zUgVdc2'),
          numParticipants: 0,
          maxParticipants: 50,
          description: 'Description for Dummy Event 1',
          tags: ['tag1', 'tag2'],
        ),
        Event(
          id: 'event2',
          title: 'Dummy Event 2',
          time: DateTime.now(),
          place: 'Place 2',
          organizer: db.collection('user').doc('ehTPHh3iv2gXJ0R649p47zUgVdc2'),
          numParticipants: 0,
          maxParticipants: 30,
          description: 'Description for Dummy Event 2',
          tags: ['tag3', 'tag4'],
        ),
      ];

      for (var event in dummyEvents) {
        await eventsCollection.doc(event.id).set(event.toFirestore());
      }
      print('Dummy events added to Firestore');
    } catch (e) {
      print('Error adding dummy events: $e');
      rethrow;
    }
  }
}
