import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/scoring.dart';
import '../../state/providers.dart';
import '../game/game_screen.dart';
import '../share/share_sheet.dart';

void startGame(BuildContext context, WidgetRef ref) {
  ref.read(gameProvider.notifier).start();
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GameScreen()));
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(sessionProvider)!;
    final played = ref.playedToday();
    final history = ref.history();
    final today = ref.watch(todayProvider);
    final server = ref.watch(serverProvider);
    ref.watch(revisionProvider);
    final yesterday = server.daily(today.subtract(const Duration(days: 1)));
    final yRank = yesterday.indexWhere((r) => r.playerId == me.id) + 1;
    final monthDays = history.where((r) => today.difference(r.day).inDays < 30).length.clamp(0, 15);

    return ListView(
      key: Key(played ? 'home-done' : 'home'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        TabHeader(
          title: 'سلام ${me.name.split(' ').first}',
          subtitle: played ? 'خسته نباشی!' : 'آماده مسابقه امروز هستی؟',
          points: ref.totalPoints(),
          leading: Avatar(me.avatar, size: 48),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              played ? _DoneCard(today: today) : const _StartCard(),
              const SectionTitle('بازی‌های امروز', trailing: '۵ بازی'),
              const _GamesRow(),
              const SizedBox(height: 16),
              AppCard(
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: C.warningTint, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.emoji_events_outlined, color: C.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(played ? 'رتبه فعلی امروز' : 'نتیجه روز گذشته', style: T.caption),
                      Text(
                        played
                            ? fa(server.dailyRank(me.id, today))
                            : 'رتبه دیروز: ${fa(yRank)} از ${fa(yesterday.length)}',
                        style: T.label.copyWith(fontSize: 16),
                      ),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.calendar_month_outlined, color: C.accentFill),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('جدول ماهانه', style: T.label)),
                    Text('${fa(monthDays)} از ۱۵ روز ثبت شده', style: T.caption),
                  ]),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: monthDays / 15,
                    minHeight: 8,
                    color: C.accent,
                    backgroundColor: C.surfaceAlt,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 6),
                  const Text('امتیاز ماهانه = مجموع ۱۵ روز بهتر تو', style: T.caption),
                ]),
              ),
              if (played) ...[
                const SizedBox(height: 12),
                AppCard(
                  border: const Border(right: BorderSide(color: C.support, width: 4)),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('دوستانت را دعوت کن', style: T.label),
                        const Text('هر دعوت ۵۰ امتیاز هدیه', style: T.caption),
                        const SizedBox(height: 6),
                        TintChip(me.referralCode),
                      ]),
                    ),
                    SizedBox(
                      width: 96,
                      child: FilledButton(
                        key: const Key('invite'),
                        style: FilledButton.styleFrom(backgroundColor: C.accentFill, shape: const StadiumBorder()),
                        onPressed: () => showShareSheet(context, code: me.referralCode),
                        child: const Text('دعوت', style: TextStyle(fontFamily: T.family, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StartCard extends ConsumerWidget {
  const _StartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TintChip('مسابقه امروز', icon: Icons.local_fire_department_outlined, fg: Colors.white, bg: Color(0x33000000)),
            const SizedBox(height: 12),
            Text('چالش ذهن و دقت', style: T.title.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            Row(children: [
              _fact('۱۵ چالش'),
              const SizedBox(width: 8),
              _fact('۹۰ ثانیه'),
              const SizedBox(width: 8),
              _fact('حداکثر ${fa(Rules.maxScore)}'),
            ]),
            const SizedBox(height: 16),
            PrimaryButton(key: const Key('start-game'), label: 'شروع بازی', icon: Icons.play_arrow_rounded, white: true, onPressed: () => startGame(context, ref)),
            const SizedBox(height: 10),
            Center(child: Text('فقط یک تلاش رسمی در روز', style: T.caption.copyWith(color: Colors.white))),
          ],
        ),
      );

  Widget _fact(String t) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: const Color(0x40000000), borderRadius: BorderRadius.circular(14)),
          child: Text(t, textAlign: TextAlign.center, style: T.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
}

class _DoneCard extends ConsumerWidget {
  const _DoneCard({required this.today});
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.history().first;
    final me = ref.watch(sessionProvider)!;
    return AppCard(
      key: const Key('done-card'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const TintChip('بازی امروز انجام شد', icon: Icons.check_circle_outline, fg: C.success, bg: C.successTint),
          const SizedBox(height: 12),
          Text(fa(r.score), style: T.display.copyWith(color: C.accentFill, fontSize: 40)),
          Text('امتیاز امروز - ${fa(r.correct)} از ۱۵ درست', style: T.caption),
          const Divider(height: 28, color: C.divider),
          StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
            builder: (context, _) {
              final now = DateTime.now();
              final left = DateTime(now.year, now.month, now.day + 1).difference(now);
              return Row(children: [
                const Icon(Icons.schedule_rounded, color: C.text2, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('مسابقه بعدی تا', style: T.label)),
                Text('${fa2(left.inHours)}:${fa2(left.inMinutes % 60)}:${fa2(left.inSeconds % 60)}', style: T.title),
              ]);
            },
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            key: const Key('share-today'),
            label: 'اشتراک‌گذاری نتیجه',
            icon: Icons.share_outlined,
            onPressed: () => showShareSheet(context, score: r.score, correct: r.correct, code: me.referralCode),
          ),
        ],
      ),
    );
  }
}

class _GamesRow extends StatelessWidget {
  const _GamesRow();

  static const games = [
    (Icons.remove_red_eye_outlined, 'تفاوت'),
    (Icons.blur_on_rounded, 'ناپدید'),
    (Icons.pin_outlined, 'شمارش'),
    (Icons.compare_outlined, 'یکسان؟'),
    (Icons.style_outlined, 'جفت‌ها'),
  ];

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final (i, g) in games.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.divider, width: 1.5)),
                child: Column(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(12)),
                    child: Icon(g.$1, color: C.accentFill, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(g.$2, style: T.caption.copyWith(color: C.text)),
                ]),
              ),
            ),
          ],
        ],
      );
}
