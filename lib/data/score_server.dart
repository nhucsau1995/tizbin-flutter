import '../domain/challenge_generator.dart';
import '../domain/models.dart';
import '../domain/scoring.dart';
import 'sample_data.dart';

/// Why the server refused or flagged a submission.
enum SubmitStatus { accepted, flagged, alreadyPlayed }

class SubmitResult {
  const SubmitResult(this.status, this.result, {this.flagReason});
  final SubmitStatus status;
  final DailyResult? result;
  final String? flagReason;
}

/// Stand-in for the backend (Firebase Cloud Functions or a Supabase Edge Function in
/// production). It owns the rules the client must not be trusted with:
/// - regenerates the day's challenges from the seed and re-scores the answer log;
/// - keeps one official attempt per player per day;
/// - flags impossible speed and many accounts on one device for admin review.
/// Everything is in memory so the POC runs offline on any emulator.
class ScoreServer {
  ScoreServer({SampleData? data}) : _data = data ?? SampleData.build();

  final SampleData _data;
  final Map<String, Set<String>> _accountsByDevice = {};

  SampleData get data => _data;

  void registerDevice(String deviceId, String playerId) =>
      (_accountsByDevice[deviceId] ??= {}).add(playerId);

  bool hasPlayed(String playerId, DateTime day) =>
      _data.results.any((r) => r.playerId == playerId && _sameDay(r.day, day));

  SubmitResult submit({
    required String playerId,
    required String deviceId,
    required DateTime day,
    required List<AnswerLog> answers,
  }) {
    if (hasPlayed(playerId, day)) return const SubmitResult(SubmitStatus.alreadyPlayed, null);

    final challenges = ChallengeGenerator(day).build();
    var used = 0;
    var correct = 0;
    var counted = 0;
    for (final a in answers) {
      if (a.index < 0 || a.index >= challenges.length) continue;
      if (used + a.elapsedMs > Rules.totalMs) {
        used = Rules.totalMs;
        break; // answers after the clock ran out do not count
      }
      used += a.elapsedMs;
      counted++;
      if (isCorrect(challenges[a.index], a)) correct++;
    }
    final result = DailyResult(
      playerId: playerId,
      day: day,
      correct: correct,
      timeMs: used,
      score: scoreFor(correct: correct, usedMs: used),
    );

    String? flag;
    if (counted > 0 && used / counted < Rules.minAvgAnswerMs) {
      flag = 'too-fast';
    } else if ((_accountsByDevice[deviceId]?.length ?? 0) > 2) {
      flag = 'multi-account';
    }

    _data.results.add(result);
    if (flag != null) {
      _data.flags.insert(
        0,
        ScoreFlag(id: 'f-$playerId-${day.day}', userLabel: playerId, reason: flag, detail: '${result.score}'),
      );
      return SubmitResult(SubmitStatus.flagged, result.withRank(dailyRank(playerId, day)), flagReason: flag);
    }
    return SubmitResult(SubmitStatus.accepted, result.withRank(dailyRank(playerId, day)));
  }

  /// Daily board: accuracy first, then speed. Flagged results wait for review.
  List<LeaderRow> daily(DateTime day) {
    final pending = {for (final f in _data.flags) if (f.status != FlagStatus.approved) f.userLabel};
    final rows = _data.results.where((r) => _sameDay(r.day, day) && !pending.contains(r.playerId)).toList()
      ..sort(compareResults);
    return [
      for (var i = 0; i < rows.length; i++)
        LeaderRow(
          rank: i + 1,
          playerId: rows[i].playerId,
          name: _data.player(rows[i].playerId).name,
          avatar: _data.player(rows[i].playerId).avatar,
          score: rows[i].score,
          correct: rows[i].correct,
          timeMs: rows[i].timeMs,
        ),
    ];
  }

  /// Monthly board: each player's best 15 daily scores over the last 30 days
  /// (a rolling month keeps the board full on the 1st; production uses the calendar month).
  List<LeaderRow> monthly(DateTime day) {
    final byPlayer = <String, List<DailyResult>>{};
    for (final r in _data.results) {
      final age = day.difference(r.day).inDays;
      if (age >= 0 && age < 30) (byPlayer[r.playerId] ??= []).add(r);
    }
    final totals = byPlayer.entries
        .map((e) => (id: e.key, score: monthlyScore(e.value.map((r) => r.score)), correct: e.value.fold(0, (s, r) => s + r.correct)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return [
      for (var i = 0; i < totals.length; i++)
        LeaderRow(
          rank: i + 1,
          playerId: totals[i].id,
          name: _data.player(totals[i].id).name,
          avatar: _data.player(totals[i].id).avatar,
          score: totals[i].score,
          correct: totals[i].correct,
        ),
    ];
  }

  int dailyRank(String playerId, DateTime day) {
    final row = daily(day).where((r) => r.playerId == playerId);
    return row.isEmpty ? 0 : row.first.rank;
  }

  List<DailyResult> history(String playerId) =>
      _data.results.where((r) => r.playerId == playerId).toList()..sort((a, b) => b.day.compareTo(a.day));

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
