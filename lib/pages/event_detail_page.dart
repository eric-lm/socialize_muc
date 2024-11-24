import 'package:flutter/material.dart';
import 'package:socialize/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialize/models/event_participation.dart';
import 'package:socialize/pages/events_page.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title

            // Event Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "${event.time.day}.${event.time.month}.${event.time.year} at ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Event Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  event.place.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Participants
            Text(
              "Participants: ${event.numParticipants} ${event.maxParticipants > 0 ? '(max: ${event.maxParticipants})' : ''}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            // Tags
            if (event.tags.isNotEmpty) ...[
              Text(
                "Tags:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: event.tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(color: Colors.white),),
                    backgroundColor: Colors.orange,
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],

            // Description
            Text(
              "Description:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 16),
            Text(
              "Created by:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("user")
                    .doc(event.organizer.id)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text("No Organizer found"));
                  } else {
                    return Text(
                        snapshot.data!['display_name'] ?? 'Anonymous Creator');
                  }
                }),
            SizedBox(
              height: 16,
            ),
            Center(
                child: FutureBuilder(
                    future: isUserAssigned(
                        event, FirebaseAuth.instance.currentUser!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text("No Organizer found"));
                      } else {
                        if (snapshot.data!) {
                          return ElevatedButton(
                              onPressed: () async {
                                DocumentReference userRef = FirebaseFirestore
                                    .instance
                                    .collection('user')
                                    .doc(
                                        FirebaseAuth.instance.currentUser!.uid);
                                DocumentReference eventRef = FirebaseFirestore
                                    .instance
                                    .collection("event")
                                    .doc(event.id);
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('event_participation')
                                    .where('user', isEqualTo: userRef)
                                    .where('event', isEqualTo: eventRef)
                                    .get();
                                if (snapshot.docs.isNotEmpty) {
                                  // If there are matching documents, delete them
                                  for (var doc in snapshot.docs) {
                                    await doc.reference.delete();
                                  }
                                  print(
                                      "Event participation deleted successfully.");
                                } else {
                                  print(
                                      "No matching event participation found.");
                                }
                                Navigator.pop(context, true);
                              },
                              child: Text('Deregister from event'));
                        } else {
                          return ElevatedButton(
                            onPressed: () async {
                              DocumentReference userRef = FirebaseFirestore
                                  .instance
                                  .collection("user")
                                  .doc(FirebaseAuth.instance.currentUser!.uid);
                              DocumentReference eventRef = FirebaseFirestore
                                  .instance
                                  .collection("event")
                                  .doc(event.id);
                              print(userRef);
                              print(eventRef);
                              await FirebaseFirestore.instance
                                  .collection('event_participation')
                                  .add((EventParticipation(
                                          user: userRef, event: eventRef))
                                      .toFirestore());

                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              "Accept Invitation",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }
                      }
                    })),
          ],
        ),
      ),
    );
  }
}
