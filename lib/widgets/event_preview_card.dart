import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'preview_card.dart';
import 'package:socialize/models/event.dart';
import 'package:socialize/pages/events_page.dart';

class EventPreviewCard extends StatelessWidget {
  final List<Event> events;
  final double width;
  final double height;

  const EventPreviewCard({
    Key? key,
    required this.events,
    required this.width,
    required this.height,
  }) : super(key: key);

  Event? getNextEvent() {
    if (events.isEmpty) return null;
    final now = DateTime.now();
    final upcomingEvents = events
        .where((event) => event.time.isAfter(now))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return upcomingEvents.isEmpty ? null : upcomingEvents.first;
  }

  @override
  Widget build(BuildContext context) {
    final nextEvent = getNextEvent();

    return PreviewCard(
      width: width,
      height: height,
      destinationPage: EventsPage(title: 'Events', events: events),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nextEvent != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Event',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextEvent.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nextEvent.description,
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${nextEvent.time.day}/${nextEvent.time.month} ${nextEvent.time.hour}:${nextEvent.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${nextEvent.numParticipants}/${nextEvent.maxParticipants}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (nextEvent.tags.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            nextEvent.tags.first,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              )
            : const Center(
                child: Text(
                  'No upcoming events',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}