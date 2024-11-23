import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:socialize/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/pages/event_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsPage extends StatefulWidget {
  final String title;
  final List<Event> events;

  EventsPage({required this.title, required this.events});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          final event = widget.events[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                              event: event,
                            ))).then((_) {
                  setState(() {});
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        FutureBuilder(
                            future: isUserAssigned(
                                event, FirebaseAuth.instance.currentUser!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text("No events found"));
                              } else {
                                return snapshot.data!
                                    ? Icon(Icons.check)
                                    : Icon(Icons.question_mark);
                              }
                            })
                      ],
                    ),
                    // Event Title
                    SizedBox(height: 8),

                    // Event Time and Place
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "${event.time.day}.${event.time.month}.${event.time.year} at ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          event.place.toString(),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Participants
                    Text(
                      "Participants: ${event.numParticipants} ${event.maxParticipants == 0 ? '' : '(max: ${event.maxParticipants})'}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),

                    // Tags
                    Wrap(
                      spacing: 8,
                      children: event.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    // Organizer Info

                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("user")
                            .doc(event.organizer.id)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData) {
                            return const Center(
                                child: Text("No Organizer found"));
                          } else {
                            return Text("Created by: " +
                                    snapshot.data!['display_name'] ??
                                'Anonymous Creator');
                          }
                        }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<bool> isUserAssigned(Event event, User user) async {
  DocumentReference eventRef =
      FirebaseFirestore.instance.collection("event").doc(event.id);
  DocumentReference userRef =
      FirebaseFirestore.instance.collection('user').doc(user.uid);

  final querySnapshot = await FirebaseFirestore.instance
      .collection('event_participation')
      //.doc('d8Ae5SmOu1D2YRMdhuaD')
      .where('user', isEqualTo: userRef)
      .get();

  Set<String> assignedEvents = await querySnapshot.docs
      .map((doc) => (doc.get('event') as DocumentReference).id)
      .toSet();
  print(assignedEvents);
  print(eventRef.id);
  print(assignedEvents.contains(eventRef.id));
  return assignedEvents.contains(eventRef.id);
}
