import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:socialize/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/pages/event_detail_page.dart';

class EventsPage extends StatelessWidget {
  final String title;
  final List<Event> events;

  EventsPage({required this.title, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => EventDetailPage(
                              event: event,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
