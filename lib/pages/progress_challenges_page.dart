import 'package:flutter/material.dart';
import '../helper/pair.dart';
import '../models/challenge.dart';

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ProgressChallengesPage extends StatelessWidget {
  final List<Pair<Challenge, int?>> challenges;

  const ProgressChallengesPage({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    // Filter only progress challenges
    final progressChallenges =
        challenges.where((c) => c.a.type == ChallengeType.PROGRESS).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Challenges'),
      ),
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
                child: _buildChallengeTimeline(context, progressChallenges.map((ch) => ch.a).toList()),
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

  Widget _buildChallengeTimeline(
      BuildContext context, List<Challenge> challenges) {
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
                      color: Colors.grey,
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
    Color iconColor = challenge.type == ChallengeType.WEEKLY
        ? Colors.blue
        : challenge.type == ChallengeType.MONTHLY
            ? Colors.green
            : Colors.amber;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              iconColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getChallengeTypeIcon(challenge.type),
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildDifficultyBadge(challenge.type.name),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.text),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: 0, // TODO: Use ChallengeProgress
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.WEEKLY:
        return Icons.event;
      case ChallengeType.MONTHLY:
        return Icons.calendar_month;
      case ChallengeType.PROGRESS:
        return Icons.trending_up;
    }
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
