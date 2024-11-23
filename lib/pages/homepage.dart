import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/models/challenge.dart';
import 'package:socialize/models/event.dart';
import 'package:socialize/widgets/event_preview_card.dart';
import 'package:socialize/models/event.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.events, required this.challenges});

  final List<Event> events;
  final List<Challenge> challenges;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    print('HomePage initialized');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EventPreviewCard(
                    events: widget.events,
                    width: constraints.maxWidth, // 90% of screen width
                    height: 200, // Fixed height
                  ),
                ),
                // Add other widgets here
              ],
            ),
          ),
        );
      },
    );
  }
}
