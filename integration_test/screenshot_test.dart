import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tizbin/app.dart';
import 'package:flutter/material.dart';
import 'package:tizbin/state/providers.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (t) async {
    await t.pumpWidget(const ProviderScope(child: TizbinApp()));
    await binding.convertFlutterSurfaceToImage();
    await waitFor(t, find.byKey(const Key('welcome')));

    Future<void> shot(String name) async {
      await pumpFor(t, 900);
      await binding.takeScreenshot(name);
    }

    await shot('01-welcome');
    await tapKey(t, 'start');
    await shot('02-register');
    await tapKey(t, 'register-submit');
    await waitFor(t, find.byKey(const Key('start-game')));
    await shot('03-home');

    await tapKey(t, 'start-game', settleMs: 400);
    // One still per game type, taken mid-board, then answered.
    const names = ['04-game-find-different', '05-game-which-disappeared', '06-game-count', '07-game-same-or-different', '08-game-match-pairs'];
    for (var i = 0; i < 15; i++) {
      if (i < 5) {
        final c = containerOf(t).read(gameProvider)!.current;
        await waitFor(t, find.byKey(Key('board-${c.type.name}')));
        if (i == 1) await waitFor(t, find.text('کدام تصویر ناپدید شد؟'), timeoutMs: 5000);
        if (i == 4) {
          // Show the match board with one pair found and one card turned.
          final pieces = c.pieces.toSet().toList();
          await tapKey(t, 'card-${pieces[0].kind.name}-a', settleMs: 200);
          await tapKey(t, 'card-${pieces[0].kind.name}-b', settleMs: 300);
          await tapKey(t, 'card-${pieces[1].kind.name}-a', settleMs: 200);
          await shot(names[i]);
          await tapKey(t, 'card-${pieces[1].kind.name}-b', settleMs: 300);
          await tapKey(t, 'card-${pieces[2].kind.name}-a', settleMs: 200);
          await tapKey(t, 'card-${pieces[2].kind.name}-b', settleMs: 200);
          await waitFor(t, find.byWidgetPredicate((w) => w.key == const Key('feedback-none') || w.key == const Key('submitting')));
          continue;
        }
        await shot(names[i]);
      }
      await playOne(t, paceMs: 150, wrong: i == 8);
    }
    await waitFor(t, find.byKey(const Key('result')), timeoutMs: 20000);
    await shot('09-result');
    await tapKey(t, 'see-ranks', settleMs: 1200);
    await shot('10-leaderboard');
    await tapKey(t, 'board-monthly');
    await shot('11-leaderboard-monthly');
    await tapKey(t, 'tab-history');
    await shot('12-history');
    await tapKey(t, 'tab-profile');
    await shot('13-profile');
    await tapKey(t, 'admin-link', settleMs: 1200);
    await shot('14-admin');
    await tapKey(t, 'back');
    await tapKey(t, 'tab-home');
    await shot('15-home-after-play');
  });
}
