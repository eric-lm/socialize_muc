import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:socialize/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/pages/event_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialize/pages/event_creation_page.dart';
import 'dart:io';
import 'dart:core';

class EventsPage extends StatefulWidget {
  final String title;
  final List<Event> initialEvents;

  EventsPage({required this.title, required this.initialEvents});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
    listenToChangeOfCategories();
  }

  Future<List<Event>> _loadEvents() async {
    try {
      var eventSnapshot =
          await FirebaseFirestore.instance.collection('event').get();
      List<Event> events = eventSnapshot.docs
          .map((doc) => Event.fromFirestore(doc, null))
          .toList();

      events =
          events.where((event) => event.time.isAfter(DateTime.now())).toList();

      events.sort((e1, e2) {
        return e1.time.compareTo(e2.time);
      });
      events = await sortEvents(events);

      return events;
    } catch (e) {
      print("Error loading events: $e");
      return List.empty();
    }
  }

  listenToChangeOfCategories() {
    final collection = FirebaseFirestore.instance.collection('event');
    final listener = collection.snapshots().listen((change) {
      if (change.docChanges.isNotEmpty) {
        return _refreshEvents();
      }
    });
    listener.onDone(() {
      listener.cancel();
    });
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No events found"));
            } else {
              List<Event> events = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(event: event),
                          ),
                        );
                        if (result == true) {
                          _refreshEvents();
                        }
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
                                    future: isUserAssigned(event,
                                        FirebaseAuth.instance.currentUser!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                "Error: ${snapshot.error}"));
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
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "${event.time.day}.${event.time.month}.${event.time.year} at ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  event.place.toString(),
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            FutureBuilder<int>(
                              future: _getParticipantCount(event),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("Loading...",
                                      style:
                                          TextStyle(color: Colors.grey[400]));
                                } else if (snapshot.hasError) {
                                  return Text("Error",
                                      style:
                                          TextStyle(color: Colors.grey[400]));
                                } else {
                                  return Text(
                                    "Participants: ${snapshot.data} ${event.maxParticipants == 0 ? '' : '(max: ${event.maxParticipants})'}",
                                    style: TextStyle(color: Colors.grey[400]),
                                  );
                                }
                              },
                            ),

                            SizedBox(height: 8),
                            // Tags
                            Wrap(
                              spacing: 8.0,
                              children: event.tags.map((tag) {
                                return Chip(
                                  label: Text(
                                    tag,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                  elevation: 0, // Entfernt den Schlagschatten
                                  side: BorderSide
                                      .none, // Entfernt die Umrandung (Rand)
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCreationPage(),
            ),
          );
        },
        child: Icon(Icons.add),
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
      .where('user', isEqualTo: userRef)
      .get();

  Set<String> assignedEvents = await querySnapshot.docs
      .map((doc) => (doc.get('event') as DocumentReference).id)
      .toSet();
  return assignedEvents.contains(eventRef.id);
}

Future<int> _getParticipantCount(Event event) async {
  var eventRef = FirebaseFirestore.instance.collection('event').doc(event.id);
  try {
    final querySnapshot = await eventRef.get();
    print(querySnapshot.data()?['num_participants'] ?? 0);
    return querySnapshot.data()?['num_participants'] ?? 0;
  } catch (e) {
    print("Error fetching participant count: $e");
    return 0;
  }
}

Future<List<Event>> sortEvents(List<Event> events) async {
  List<Map<String, dynamic>> eventsWithAssignmentStatus = [];

  User user = FirebaseAuth.instance.currentUser!;

  for (var event in events) {
    bool isAssigned = await isUserAssigned(event, user);
    eventsWithAssignmentStatus.add({
      'event': event,
      'isAssigned': isAssigned,
    });
  }

  eventsWithAssignmentStatus.sort((a, b) {
    bool assigned1 = a['isAssigned'];
    bool assigned2 = b['isAssigned'];

    if (assigned1 == assigned2) {
      return 0;
    }
    return assigned1 ? -1 : 1;
  });

  List<Event> sortedEvents = eventsWithAssignmentStatus
      .map((entry) => entry['event'] as Event)
      .toList();

  return sortedEvents;
}
