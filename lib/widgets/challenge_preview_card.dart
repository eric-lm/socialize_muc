import 'package:flutter/material.dart';
import 'package:socialize/models/challenge.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../helper/pair.dart';
import 'preview_card.dart';
import 'package:socialize/pages/progress_challenges_page.dart';
import 'package:socialize/pages/reoccuring_challenges_page.dart';

class ChallengePreviewCard extends StatelessWidget {
  final List<Pair<Challenge, int?>> challenges;
  final double width;
  final double height;
  final ChallengeType challengeType;
  final String title;

  const ChallengePreviewCard({
    Key? key,
    required this.challenges,
    required this.width,
    required this.height,
    required this.challengeType,
    required  this.title,
  }) : super(key: key);

  List<Pair<Challenge, int?>> getFilteredChallenges() {
    return challenges.where((challenge) {
      return challenge.a.type == challengeType;
    }).toList();
  }

  Map<ChallengeType, String> getChallengeTypeTimeLeft() => <ChallengeType, String> {
      ChallengeType.MONTHLY: "3 days left",
      ChallengeType.WEEKLY: "7 hours left"
    };

  Pair<Challenge, int?>? getNextChallenge() {
    final filteredChallenges = getFilteredChallenges();
    if (filteredChallenges.isEmpty) return null;
    return filteredChallenges.firstWhere((ch) => ch.b != null);
  }

  @override
  Widget build(BuildContext context) {
    final nextChallenge = getNextChallenge();
    final destinationPage = challengeType == ChallengeType.PROGRESS
        ? ProgressChallengesPage(challenges: getFilteredChallenges())
        : ReoccurringChallengesPage(challenges: challenges.where((ch) => ch.a.type != ChallengeType.PROGRESS).toList());

    return PreviewCard(
      width: width,
      height: challengeType == ChallengeType.PROGRESS ? height - 30 : height,
      destinationPage: destinationPage,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nextChallenge != null
            ? Row(
                children: [
                  Icon(Icons.keyboard_double_arrow_up),
                  SizedBox(width: 30),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nextChallenge.a.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nextChallenge.a.text,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      StepProgressIndicator(
                        totalSteps: getNextChallenge()?.a.maxProgress ?? 0,
                        currentStep: getNextChallenge()?.b ?? 0,
                        selectedColor: Colors.tealAccent,
                        unselectedColor: Colors.grey,
                        size: 10,
                      ),
                      if (nextChallenge.a.type != ChallengeType.PROGRESS)
                        const SizedBox(height: 16),
                      if (nextChallenge.a.type != ChallengeType.PROGRESS)
                        Text(
                            getChallengeTypeTimeLeft()[nextChallenge.a.type] ?? "",
                            style: TextStyle(color: Colors.grey[400]),
                        ),
                    ],
                  ))
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
