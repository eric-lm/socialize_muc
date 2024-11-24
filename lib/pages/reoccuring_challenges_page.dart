import 'package:flutter/material.dart';
import '../helper/pair.dart';
import '../models/challenge.dart';

class ReoccurringChallengesPage extends StatelessWidget {
  final List<Pair<Challenge, int?>> challenges;

  const ReoccurringChallengesPage({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    final reoccurringChallenges = challenges
        .where((c) => c.a.type == ChallengeType.WEEKLY || c.a.type == ChallengeType.MONTHLY)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reoccurring Challenges'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly & Monthly Challenges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: reoccurringChallenges.length,
                  itemBuilder: (context, index) {
                    return _buildChallengeCard(reoccurringChallenges[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Pair<Challenge, int?> challenge) {
    Color iconColor =
        challenge.a.type == ChallengeType.WEEKLY ? Colors.blue : Colors.green;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                      challenge.a.type == ChallengeType.WEEKLY
                          ? Icons.event
                          : Icons.calendar_month,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.a.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          challenge.a.type.name,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.a.text),
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
}
