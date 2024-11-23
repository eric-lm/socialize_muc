import 'package:socialize/models/event.dart';
import 'package:socialize/models/challenge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as user_model;

Future<List<Event>> getEvents() async {
  final snapshot = await FirebaseFirestore.instance.collection('event').get();
  return snapshot.docs.map((doc) => Event.fromFirestore(doc, null)).toList();
}

Future<List<Challenge>> getChallenges() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('challenge').get();
  return snapshot.docs
      .map((doc) => Challenge.fromFirestore(doc, null))
      .toList();
}

Future<Challenge?> getChallengeById(String challengeId) async {
  try {
    print('Fetching challenge with ID: $challengeId');
    final docSnapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .get();

    if (!docSnapshot.exists) {
      print('No challenge found with ID: $challengeId');
      return null;
    }

    print('Found challenge document, converting to Challenge object');
    return Challenge.fromFirestore(docSnapshot, null);
  } catch (e) {
    print('Error fetching challenge: $e');
    rethrow;
  }
}

Stream<user_model.User> getCurrentUser() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('No user logged in');

  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    return user_model.User.fromFirestore(snapshot, null);
  });
}
