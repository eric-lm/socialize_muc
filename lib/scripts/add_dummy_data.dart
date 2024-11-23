import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialize/models/event.dart';
import 'package:socialize/models/challenge.dart';
import '../../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var db = FirebaseFirestore.instance;

  await addDummyEvents(db);
  await addDummyChallenges(db);
}

Future<void> addDummyEvents(FirebaseFirestore db) async {
  final eventsCollection = db.collection('event');
  final existingEvents = await eventsCollection.get();

  if (existingEvents.docs.isEmpty) {
    final dummyEvents = [
      Event(
        id: 'event1',
        title: 'Dummy Event 1',
        time: DateTime.now(),
        place: 'Place 1',
        organizer: db.collection('user').doc('organizer1'),
        numParticipants: 10,
        maxParticipants: 5,
        description: 'Description for Dummy Event 1',
        tags: ['tag1', 'tag2'],
      ),
      Event(
        id: 'event2',
        title: 'Dummy Event 2',
        time: DateTime.now(),
        place: 'Place 2',
        organizer: db.collection('user').doc('organizer2'),
        numParticipants: 20,
        maxParticipants: 10,
        description: 'Description for Dummy Event 2',
        tags: ['tag3', 'tag4'],
      ),
    ];

    for (var event in dummyEvents) {
      await eventsCollection.doc(event.id).set(event.toFirestore());
    }
    print('Dummy events added to Firestore');
  } else {
    print('Events already exist in Firestore');
  }
}

Future<void> addDummyChallenges(FirebaseFirestore db) async {
  final challengesCollection = db.collection('challenge');
  final existingChallenges = await challengesCollection.get();

  if (existingChallenges.docs.isEmpty) {
    final dummyChallenges = [
      Challenge(
        id: 'challenge1',
        title: 'Dummy Challenge 1',
        text: 'Description for Dummy Challenge 1',
        maxProgress: 100,
        isUserCompletable: true,
        type: Type.WEEKLY,
        level: 1,
      ),
      Challenge(
        id: 'challenge2',
        title: 'Dummy Challenge 2',
        text: 'Description for Dummy Challenge 2',
        maxProgress: 200,
        isUserCompletable: true,
        type: Type.MONTHLY,
        level: 2,
      ),
    ];

    for (var challenge in dummyChallenges) {
      await challengesCollection.doc(challenge.id).set(challenge.toFirestore());
    }
    print('Dummy challenges added to Firestore');
  } else {
    print('Challenges already exist in Firestore');
  }
}
