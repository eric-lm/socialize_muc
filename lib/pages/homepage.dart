import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final String date;
  final String location;
  final int attendees;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.attendees,
  });
}

class Challenge {
  final IconData icon;
  final String title;
  final String description;
  final String difficulty;
  final int progress;
  final bool unlocked;
  final Color iconColor;

  Challenge({
    required this.icon,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.progress,
    required this.unlocked,
    required this.iconColor,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<Event> events = [
    Event(
      title: "Local Meetup: Tech Enthusiasts",
      description:
          "Join fellow tech lovers for an evening of networking and fun!",
      date: "Friday, June 15th, 2024 at 7:00 PM",
      location: "TechHub Coworking Space, 123 Innovation St.",
      attendees: 24,
    ),
    Event(
      title: "Virtual Workshop: Public Speaking",
      description:
          "Improve your communication skills with our expert-led workshop.",
      date: "Saturday, June 16th, 2024 at 2:00 PM",
      location: "Online (Zoom)",
      attendees: 50,
    ),
    Event(
      title: "Outdoor Adventure: Hiking Club",
      description: "Explore nature and make new friends on our group hike!",
      date: "Sunday, June 17th, 2024 at 9:00 AM",
      location: "Greenvalley Park, Trail Entrance",
      attendees: 15,
    ),
  ];

  final List<Challenge> challenges = [
    Challenge(
      icon: Icons.message,
      title: "Start 5 Conversations",
      description: "Initiate chats with new people",
      difficulty: "Easy",
      progress: 60,
      unlocked: true,
      iconColor: Colors.blue,
    ),
    Challenge(
      icon: Icons.group,
      title: "Attend a Meetup",
      description: "Join a local event in your area",
      difficulty: "Medium",
      progress: 0,
      unlocked: true,
      iconColor: Colors.green,
    ),
    Challenge(
      icon: Icons.book,
      title: "Complete Your Profile",
      description: "Add more details about yourself",
      difficulty: "Easy",
      progress: 80,
      unlocked: true,
      iconColor: Colors.amber,
    ),
    Challenge(
      icon: Icons.emoji_events,
      title: "Win a Debate",
      description: "Participate and win in a forum debate",
      difficulty: "Hard",
      progress: 30,
      unlocked: false,
      iconColor: Colors.purple,
    ),
  ];

  Challenge getNextChallenge() {
    return challenges.firstWhere((challenge) => !challenge.unlocked,
        orElse: () => challenges.first);
  }

  @override
  Widget build(BuildContext context) {
    Challenge nextChallenge = getNextChallenge();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNextChallengePreview(nextChallenge),
            const SizedBox(height: 24),
            const Text(
              'Time Limited Events',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeLimitedEventPreview(events[0]), // Example event
            const SizedBox(height: 24),
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: events.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildEventCard(events[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                events.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextChallengePreview(Challenge challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: challenge.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                challenge.icon,
                color: challenge.iconColor,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Difficulty: ${challenge.difficulty}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              color: Colors.blue,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLimitedEventPreview(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timer,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${event.date}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${event.location}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              color: Colors.blue,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.calendar_today, event.date),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, event.location),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.people, '${event.attendees} people attending'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'RSVP Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
