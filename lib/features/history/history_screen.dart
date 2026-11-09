import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/scoring.dart';
import '../../state/providers.dart';
import '../home/home_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.history();
    final total = ref.totalPoints();
    final server = ref.watch(serverProvider);
    final me = ref.watch(sessionProvider)!;
    final played = ref.playedToday();
    if (history.isEmpty) {
      return ListView(
        key: const Key('history-empty'),
        children: [
          TabHeader(title: 'تاریخچه', points: total),
          const SizedBox(height: 32),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/history-empty.jpg', width: 260, height: 260, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: Text('هنوز بازی نکرده‌ای', style: T.title)),
          const SizedBox(height: 6),
          Center(
            child: Text('اولین مسابقه روزانه را شروع کن تا امتیازهایت اینجا ثبت شود',
                style: T.body.copyWith(color: C.text2), textAlign: TextAlign.center),
          ),
          if (!played)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: PrimaryButton(label: 'شروع بازی', icon: Icons.play_arrow_rounded, onPressed: () => startGame(context, ref)),
            ),
        ],
      );
    }
    final best = history.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    return ListView(
      key: const Key('history'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        TabHeader(title: 'تاریخچه', points: total),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('مجموع امتیاز', style: T.label.copyWith(color: Colors.white)),
                Text(fa(total), style: T.display.copyWith(color: Colors.white, fontSize: 40)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  TintChip('بهترین امتیاز ${fa(best)}', icon: Icons.star_rounded, fg: Colors.white, bg: const Color(0x40000000)),
                  TintChip('روزهای بازی ${fa(history.length)}', icon: Icons.calendar_today_outlined, fg: Colors.white, bg: const Color(0x40000000)),
                ]),
              ]),
            ),
            const SectionTitle('بازی‌های اخیر'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                for (final (i, r) in history.take(10).indexed) ...[
                  if (i > 0) const Divider(height: 1, color: C.surfaceAlt),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(children: [
                      Expanded(
                        flex: 5,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(faDayMonth(r.day), style: T.label.copyWith(fontSize: 16)),
                          Text('${fa(r.correct)}/۱۵ درست • رتبه ${fa(server.dailyRank(me.id, r.day))}', style: T.caption),
                        ]),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: r.score / Rules.maxScore,
                          minHeight: 6,
                          color: C.accent,
                          backgroundColor: C.surfaceAlt,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 56, child: Text(fa(r.score), style: T.label.copyWith(color: C.accentFill, fontSize: 16), textAlign: TextAlign.left)),
                    ]),
                  ),
                ],
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}
