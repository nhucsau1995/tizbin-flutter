import 'dart:math';

import '../domain/models.dart';
import '../domain/scoring.dart';

/// Deterministic demo data: players, 30 days of results, review flags and the
/// manual prize record. Same output on every launch so screenshots are stable.
class SampleData {
  SampleData._(this.players, this.results, this.flags, this.prizes, this.today);

  final Map<String, Player> players;
  final List<DailyResult> results;
  final List<ScoreFlag> flags;
  final List<PrizeRecord> prizes;
  final DateTime today;

  static const me = 'sara';

  Player player(String id) => players[id] ?? Player(id: id, name: id, phone: '', avatar: '', referralCode: '');

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  factory SampleData.build({DateTime? now}) {
    final today = dayOnly(now ?? DateTime.now());
    final rng = Random(42);
    final players = <String, Player>{
      me: const Player(id: me, name: 'سارا احمدی', phone: '۰۹۱۲ ۳۴۵ ۶۷۸۹', avatar: 'avatar-sara', referralCode: 'TZB-4821'),
      'reza': const Player(id: 'reza', name: 'رضا کریمی', phone: '', avatar: 'avatar-reza', referralCode: 'TZB-1102'),
      'maryam': const Player(id: 'maryam', name: 'مریم حسینی', phone: '', avatar: 'avatar-maryam', referralCode: 'TZB-1977'),
      'ali': const Player(id: 'ali', name: 'علی رضایی', phone: '', avatar: 'avatar-ali', referralCode: 'TZB-3310'),
      'nima': const Player(id: 'nima', name: 'نیما صادقی', phone: '', avatar: 'avatar-nima', referralCode: 'TZB-5521'),
      'leila': const Player(id: 'leila', name: 'لیلا موسوی', phone: '', avatar: 'avatar-leila', referralCode: 'TZB-6640'),
      'amir': const Player(id: 'amir', name: 'امیر جعفری', phone: '', avatar: 'avatar-amir', referralCode: 'TZB-7012'),
      'zahra': const Player(id: 'zahra', name: 'زهرا کاظمی', phone: '', avatar: 'avatar-zahra', referralCode: 'TZB-8235'),
    };
    const first = ['حسین', 'فاطمه', 'محمد', 'نرگس', 'مهدی', 'الهام', 'کیان', 'شیرین', 'پویا', 'آرزو', 'بهرام', 'ستاره'];
    const last = ['نوری', 'امینی', 'شریفی', 'قاسمی', 'باقری', 'مرادی', 'رحیمی', 'یوسفی', 'صالحی', 'اکبری'];
    final avatars = ['avatar-girl', 'avatar-grandpa', 'avatar-grandma', 'avatar-amir', 'avatar-leila', 'avatar-nima'];
    for (var i = 0; i < 52; i++) {
      players['p$i'] = Player(
        id: 'p$i',
        name: '${first[i % first.length]} ${last[(i * 7) % last.length]}',
        phone: '',
        avatar: avatars[i % avatars.length],
        referralCode: 'TZB-${2000 + i}',
      );
    }

    // Top players are strong and fast; the rest spread out. Today's leaders match the design.
    final results = <DailyResult>[];
    final strength = <String, double>{
      'reza': .99, 'maryam': .98, 'ali': .97, 'nima': .96, 'leila': .95, 'amir': .94, 'zahra': .93,
      for (var i = 0; i < 52; i++) 'p$i': .45 + rng.nextDouble() * .5,
    };
    for (var back = 29; back >= 0; back--) {
      final day = today.subtract(Duration(days: back));
      for (final e in strength.entries) {
        if (back > 0 && rng.nextDouble() < .25) continue; // not everyone plays every day
        final correct = (e.value * 15 + rng.nextDouble() * 2 - 1).round().clamp(5, 15);
        final timeMs = (90000 - e.value * 40000 + rng.nextInt(9000)).round().clamp(30000, 90000);
        results.add(DailyResult(playerId: e.key, day: day, correct: correct, timeMs: timeMs, score: scoreFor(correct: correct, usedMs: timeMs)));
      }
    }
    // Today's podium and rows 4-7 exactly as in the design.
    const fixed = {'reza': (15, 40000), 'maryam': (15, 70000), 'ali': (15, 90000), 'nima': (14, 20000), 'leila': (14, 40000), 'amir': (14, 60000), 'zahra': (14, 80000)};
    results.removeWhere((r) => fixed.containsKey(r.playerId) && r.day == today);
    fixed.forEach((id, v) {
      results.add(DailyResult(playerId: id, day: today, correct: v.$1, timeMs: v.$2, score: scoreFor(correct: v.$1, usedMs: v.$2)));
    });

    // Sara's own past attempts (today is still open for her).
    const mine = [(1, 12, 86000), (2, 14, 72000), (3, 10, 88000), (4, 13, 80000), (5, 11, 89000), (7, 12, 84000), (8, 13, 77000), (10, 11, 85000)];
    for (final m in mine) {
      results.add(DailyResult(
        playerId: me,
        day: today.subtract(Duration(days: m.$1)),
        correct: m.$2,
        timeMs: m.$3,
        score: scoreFor(correct: m.$2, usedMs: m.$3),
      ));
    }

    final flags = [
      const ScoreFlag(id: 'f1', userLabel: 'کاربر #۲۲۹۱', reason: 'too-fast', detail: '۱٬۵۹۰ امتیاز در ۱۱ ثانیه'),
      const ScoreFlag(id: 'f2', userLabel: 'کاربر #۱۰۴۷', reason: 'multi-account', detail: '۳ حساب روی یک دستگاه'),
    ];
    const prizes = [
      PrizeRecord(month: 'مهر', place: 'نفر اول', winner: 'رضا کریمی', recorded: false),
      PrizeRecord(month: 'شهریور', place: 'نفر اول', winner: 'مریم حسینی', recorded: true),
    ];
    return SampleData._(players, results, flags, [...prizes], today);
  }
}
