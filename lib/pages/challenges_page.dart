import 'package:flutter/material.dart';

// Challenge data model
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

// Add this custom painter class at the top level
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw simple vertical line
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ChallengesPage extends StatelessWidget {
  ChallengesPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'Your Social Journey',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildChallengeTimeline(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://via.placeholder.com/50'),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back, User!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level 5 Socializer',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.star, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text(
              '1250 points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChallengeTimeline(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.8),
          painter: PathPainter(),
        ),
        ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index % 2 == 0)
                    Expanded(child: _buildChallengeCard(challenge))
                  else
                    Expanded(child: Container()),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: challenge.unlocked
                          ? challenge.iconColor
                          : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (index % 2 == 0)
                    Expanded(child: Container())
                  else
                    Expanded(child: _buildChallengeCard(challenge)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: challenge.unlocked ? 1.0 : 0.5,
        child: Container(
          width: double.infinity, // Force full width
          constraints: const BoxConstraints(maxWidth: 600), // Limit max width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                challenge.iconColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  // Ensure row children have same height
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: challenge.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          challenge.unlocked ? challenge.icon : Icons.lock,
                          color: challenge.unlocked
                              ? challenge.iconColor
                              : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              // Add Flexible here
                              child: Text(
                                challenge.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                softWrap: true, // Enable line breaks
                                overflow: TextOverflow
                                    .fade, // Change to fade for better readability
                              ),
                            ),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child:
                                  _buildDifficultyBadge(challenge.difficulty),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  challenge.description,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Progress',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${challenge.progress}%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: challenge.progress / 100,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: challenge.unlocked ? () {} : null,
                    child: Text(
                      !challenge.unlocked
                          ? 'Locked'
                          : challenge.progress == 100
                              ? 'Claim Reward'
                              : 'Start Challenge',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = Colors.green;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
