import 'package:flutter/material.dart';
import 'package:socialize/models/challenge.dart';
import 'preview_card.dart';
import 'package:socialize/pages/progress_challenges_page.dart';
import 'package:socialize/pages/reoccuring_challenges_page.dart';

class ChallengePreviewCard extends StatelessWidget {
  final List<Challenge> challenges;
  final double width;
  final double height;
  final bool progressTrue;

  const ChallengePreviewCard({
    Key? key,
    required this.challenges,
    required this.width,
    required this.height,
    required this.progressTrue,
  }) : super(key: key);

  List<Challenge> getFilteredChallenges() {
    return challenges.where((challenge) {
      if (progressTrue) {
        return challenge.type == Type.PROGRESS;
      } else {
        return challenge.type != Type.PROGRESS;
      }
    }).toList();
  }

  Challenge? getNextChallenge() {
    final filteredChallenges = getFilteredChallenges();
    if (filteredChallenges.isEmpty) return null;
    return filteredChallenges.first;
  }

  @override
  Widget build(BuildContext context) {
    final nextChallenge = getNextChallenge();
    final destinationPage = progressTrue
        ? ProgressChallengesPage(challenges: getFilteredChallenges())
        : ReoccurringChallengesPage(challenges: getFilteredChallenges());

    return PreviewCard(
      width: width,
      height: height,
      destinationPage: destinationPage,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nextChallenge != null
            ? Row(
                children: [
                  Icon(Icons.keyboard_double_arrow_up),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Challenge',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nextChallenge.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nextChallenge.text,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'Max Progress: ${nextChallenge.maxProgress}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Type: ${nextChallenge.type.name}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  )
                ],
              )
            : const Center(
                child: Text(
                  'No challenges available',
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
