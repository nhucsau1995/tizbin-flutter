import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tizbin/app.dart';
import 'package:tizbin/data/sample_data.dart';
import 'package:tizbin/data/score_server.dart';
import 'package:tizbin/domain/models.dart';
import 'package:tizbin/state/providers.dart';

final day = DateTime(2026, 11, 9);

/// Pixel 6-like phone in logical pixels.
Future<ProviderContainer> boot(WidgetTester t, {bool signIn = true}) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 2.75;
  addTearDown(t.view.reset);
  final container = ProviderContainer(overrides: [serverProvider.overrideWithValue(ScoreServer(data: SampleData.build(now: day)))]);
  addTearDown(container.dispose);
  if (signIn) container.read(sessionProvider.notifier).logIn();
  await t.pumpWidget(UncontrolledProviderScope(container: container, child: const TizbinApp()));
  await t.pump(const Duration(milliseconds: 300));
  return container;
}

Future<void> done(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 1));
}

Future<void> tapKey(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.ensureVisible(f.last);
  await t.tap(f.last);
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('welcome and register', (t) async {
    await boot(t, signIn: false);
    expect(find.text('هر روز ۹۰ ثانیه، ۱۵ چالش'), findsOneWidget);
    await tapKey(t, 'start');
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('register')), findsOneWidget);
    expect(find.text('کد معرف معتبر است، ۵۰ امتیاز هدیه'), findsOneWidget);
    await tapKey(t, 'register-submit');
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('home')), findsOneWidget);
    await done(t);
  });

  testWidgets('home shows the start card and yesterday rank', (t) async {
    await boot(t);
    expect(find.byKey(const Key('start-game')), findsOneWidget);
    expect(find.textContaining('رتبه دیروز'), findsOneWidget);
    await done(t);
  });

  testWidgets('a full daily run through all five games ends on a validated result', (t) async {
    final c = await boot(t);
    await tapKey(t, 'start-game');
    for (var i = 0; i < 15; i++) {
      final s = c.read(gameProvider)!;
      expect(find.byKey(Key('board-${s.current.type.name}')), findsOneWidget);
      if (s.current.type == GameType.match) {
        for (final k in s.current.pieces.toSet()) {
          await tapKey(t, 'card-${k.kind.name}-a');
          await tapKey(t, 'card-${k.kind.name}-b');
        }
      } else {
        if (s.current.type == GameType.disappeared) await t.pump(const Duration(milliseconds: 2100));
        await tapKey(t, 'opt-correct');
      }
      await t.pump(const Duration(milliseconds: 500));
    }
    await t.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('result')), findsOneWidget);
    expect(find.text('امتیاز روی سرور تایید شد'), findsOneWidget);
    final r = c.read(gameProvider)!.result!;
    expect(r.status, SubmitStatus.accepted);
    expect(r.result!.correct, 15);
    await tapKey(t, 'see-ranks');
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('my-rank')), findsOneWidget);
    await tapKey(t, 'tab-home');
    expect(find.byKey(const Key('done-card')), findsOneWidget);
    await done(t);
  });

  testWidgets('a wrong answer shows red feedback', (t) async {
    await boot(t);
    await tapKey(t, 'start-game');
    await t.tap(find.byKey(const Key('opt-0')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('feedback-false')), findsOneWidget);
    await tapKey(t, 'quit');
    await done(t);
  });

  testWidgets('leaderboard daily and monthly', (t) async {
    await boot(t);
    await tapKey(t, 'tab-ranks');
    expect(find.text('رضا کریمی'), findsWidgets);
    await tapKey(t, 'board-monthly');
    expect(find.textContaining('۳۰ روز اخیر'), findsOneWidget);
    await done(t);
  });

  testWidgets('history list, profile and admin review', (t) async {
    await boot(t);
    await tapKey(t, 'tab-history');
    expect(find.byKey(const Key('history')), findsOneWidget);
    await tapKey(t, 'tab-profile');
    expect(find.text('لینک دعوت تو'), findsOneWidget);
    await tapKey(t, 'admin-link');
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('پرداخت خودکار جایزه غیرفعال است تا تایید حقوقی'), findsOneWidget);
    await tapKey(t, 'approve-f1');
    expect(find.text('تایید شد'), findsOneWidget);
    await done(t);
  });

  testWidgets('history empty state for a player without games', (t) async {
    final c = await boot(t, signIn: false);
    c.read(serverProvider).data.results.removeWhere((r) => r.playerId == SampleData.me);
    c.read(sessionProvider.notifier).logIn();
    await t.pump(const Duration(milliseconds: 300));
    await tapKey(t, 'tab-history');
    expect(find.byKey(const Key('history-empty')), findsOneWidget);
    await done(t);
  });
}
