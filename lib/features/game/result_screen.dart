import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/score_server.dart';
import '../../domain/scoring.dart';
import '../../state/providers.dart';
import '../share/share_sheet.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider)!;
    final r = s.result!;
    final res = r.result;
    final me = ref.watch(sessionProvider)!;
    void close() {
      ref.read(gameProvider.notifier).quit();
      Navigator.of(context).maybePop();
    }

    if (res == null) {
      return Scaffold(
        key: const Key('result'),
        body: Center(child: Text('امروز قبلا بازی کرده‌ای', style: T.title)),
      );
    }
    final flagged = r.status == SubmitStatus.flagged;
    return Scaffold(
      key: const Key('result'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(key: const Key('close-result'), onPressed: close, icon: const Icon(Icons.close_rounded, color: C.text2)),
            ),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: C.heroGradient, boxShadow: C.cardShadow),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(fa(res.score), key: const Key('final-score'), style: T.display.copyWith(color: Colors.white, fontSize: 32)),
                  Text('از ${fa(Rules.maxScore)}', style: T.label.copyWith(color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text('آفرین ${me.name.split(' ').first}!', style: T.display)),
            const SizedBox(height: 16),
            Row(children: [
              StatCard(label: 'درست', value: '${fa(res.correct)} از ${fa(Rules.challenges)}', icon: Icons.check_circle_outline),
              const SizedBox(width: 10),
              StatCard(label: 'پاداش سرعت', value: fa(speedBonus(res.timeMs)), icon: Icons.bolt_rounded),
              const SizedBox(width: 10),
              StatCard(label: 'زمان', value: '${fa((res.timeMs / 1000).round())} ثانیه', icon: Icons.timer_outlined),
            ]),
            const SizedBox(height: 16),
            if (!flagged) Center(child: TintChip('رتبه امروز: ${fa(res.rank ?? 0)}', icon: Icons.emoji_events_outlined)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(color: flagged ? C.warningTint : C.successTint, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(flagged ? Icons.report_gmailerrorred_rounded : Icons.verified_user_outlined, size: 20, color: flagged ? C.warning : C.success),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    flagged ? 'امتیاز برای بررسی مدیر ثبت شد' : 'امتیاز روی سرور تایید شد',
                    key: const Key('server-check'),
                    style: T.label.copyWith(color: flagged ? C.warning : C.success),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              key: const Key('share-result'),
              label: 'اشتراک‌گذاری نتیجه',
              icon: Icons.share_outlined,
              onPressed: () => showShareSheet(context, score: res.score, correct: res.correct, code: me.referralCode),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              key: const Key('see-ranks'),
              label: 'دیدن جدول رتبه‌ها',
              icon: Icons.emoji_events_outlined,
              onPressed: () {
                ref.read(tabProvider.notifier).go(1);
                close();
              },
            ),
            const SizedBox(height: 16),
            const Center(child: Text('مسابقه بعدی فردا ساعت ۰۰:۰۰', style: T.caption)),
          ],
        ),
      ),
    );
  }
}
