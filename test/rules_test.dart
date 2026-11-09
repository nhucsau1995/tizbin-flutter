import 'package:flutter_test/flutter_test.dart';
import 'package:tizbin/data/sample_data.dart';
import 'package:tizbin/data/score_server.dart';
import 'package:tizbin/data/submission_queue.dart';
import 'package:tizbin/domain/challenge_generator.dart';
import 'package:tizbin/domain/models.dart';
import 'package:tizbin/domain/scoring.dart';

List<AnswerLog> perfect(DateTime day, {int ms = 3000}) => [
      for (final c in ChallengeGenerator(day).build())
        AnswerLog(index: c.index, value: c.type == GameType.match ? 3 : c.answer, elapsedMs: ms),
    ];

void main() {
  final day = DateTime(2026, 11, 9);

  test('max score is 1,590', () {
    expect(Rules.maxScore, 1590);
    expect(scoreFor(correct: 15, usedMs: 0), 1590);
    expect(scoreFor(correct: 12, usedMs: 86000), 1204);
  });

  test('daily challenges are the same for everyone and cycle the five games', () {
    final a = ChallengeGenerator(day).build();
    final b = ChallengeGenerator(day).build();
    expect(a.length, 15);
    expect([for (final c in a) c.type], [for (var i = 0; i < 15; i++) GameType.values[i % 5]]);
    expect([for (final c in a) c.answer], [for (final c in b) c.answer]);
  });

  test('server re-scores the answer log and allows one attempt per day', () {
    final server = ScoreServer(data: SampleData.build(now: day));
    final r = server.submit(playerId: SampleData.me, deviceId: 'd1', day: day, answers: perfect(day));
    expect(r.status, SubmitStatus.accepted);
    expect(r.result!.correct, 15);
    expect(r.result!.score, 1500 + 45);
    final again = server.submit(playerId: SampleData.me, deviceId: 'd1', day: day, answers: perfect(day));
    expect(again.status, SubmitStatus.alreadyPlayed);
  });

  test('answers after 90 seconds do not count', () {
    final server = ScoreServer(data: SampleData.build(now: day));
    final r = server.submit(playerId: SampleData.me, deviceId: 'd1', day: day, answers: perfect(day, ms: 10000));
    expect(r.result!.correct, 9);
    expect(r.result!.score, 900);
  });

  test('impossibly fast runs are flagged and kept off the board', () {
    final server = ScoreServer(data: SampleData.build(now: day));
    final r = server.submit(playerId: SampleData.me, deviceId: 'd1', day: day, answers: perfect(day, ms: 100));
    expect(r.status, SubmitStatus.flagged);
    expect(server.daily(day).any((row) => row.playerId == SampleData.me), isFalse);
  });

  test('ranking: accuracy first, then speed; monthly uses the best 15 days', () {
    final rows = ScoreServer(data: SampleData.build(now: day)).daily(day);
    expect(rows.take(3).map((r) => r.name), ['رضا کریمی', 'مریم حسینی', 'علی رضایی']);
    expect(monthlyScore([for (var i = 1; i <= 20; i++) i * 10]), [for (var i = 6; i <= 20; i++) i * 10].reduce((a, b) => a + b));
  });

  test('offline queue keeps a run until it is sent', () async {
    final q = SubmissionQueue()..add(PendingSubmission(playerId: 'sara', day: day, answers: perfect(day)));
    expect(await q.flush((_) async => false), 0);
    expect(q.pending.length, 1);
    expect(await q.flush((_) async => true), 1);
    expect(q.pending, isEmpty);
  });
}
