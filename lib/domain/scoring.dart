import 'models.dart';

/// Competition rules from the brief, in one place so the app, the mock server and
/// the tests agree.
class Rules {
  static const challenges = 15;
  static const totalMs = 90 * 1000;
  static const pointsPerCorrect = 100;

  /// 15 x 100 + a 90-second bonus if the clock never ran.
  static const maxScore = challenges * pointsPerCorrect + totalMs ~/ 1000;

  /// Memory match counts as correct with at most this many wrong flips.
  static const matchMistakesAllowed = 2;

  /// Fastest believable average answer. Anything quicker is flagged for review.
  static const minAvgAnswerMs = 400;
}

/// Speed bonus: one point per whole second left on the 90-second clock.
int speedBonus(int usedMs) {
  final left = Rules.totalMs - usedMs.clamp(0, Rules.totalMs);
  return left ~/ 1000;
}

int scoreFor({required int correct, required int usedMs}) =>
    correct * Rules.pointsPerCorrect + speedBonus(usedMs);

/// Is this answer right for this challenge?
bool isCorrect(Challenge c, AnswerLog a) {
  switch (c.type) {
    case GameType.match:
      return a.value == c.pieces.length ~/ 2 && a.mistakes <= Rules.matchMistakesAllowed;
    case GameType.findDifferent:
    case GameType.disappeared:
    case GameType.count:
    case GameType.sameDifferent:
      return a.value == c.answer;
  }
}

/// Daily ranking: accuracy first, then speed.
int compareResults(DailyResult a, DailyResult b) {
  final byCorrect = b.correct.compareTo(a.correct);
  if (byCorrect != 0) return byCorrect;
  return a.timeMs.compareTo(b.timeMs);
}

/// Monthly score: the sum of a player's best 15 daily scores.
int monthlyScore(Iterable<int> dailyScores) {
  final sorted = dailyScores.toList()..sort((a, b) => b.compareTo(a));
  return sorted.take(15).fold(0, (s, v) => s + v);
}
