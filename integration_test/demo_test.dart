import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tizbin/app.dart';

import 'harness.dart';

/// Paced walkthrough for the demo GIF: register, start today's run, play all 15
/// challenges (one deliberate miss), see the validated result, the leaderboards,
/// history, profile and the admin review.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (t) async {
    await t.pumpWidget(const ProviderScope(child: TizbinApp()));
    await waitFor(t, find.byKey(const Key('welcome')));
    await pumpFor(t, 1000);
    debugPrint('POC_DEMO_START');
    await pumpFor(t, 800);
    await register(t, settleMs: 800);
    await pumpFor(t, 900);
    await tapKey(t, 'start-game', settleMs: 300);
    for (var i = 0; i < 15; i++) {
      await playOne(t, paceMs: i < 5 ? 500 : 250, wrong: i == 7);
    }
    await waitFor(t, find.byKey(const Key('result')), timeoutMs: 20000);
    await pumpFor(t, 1600);
    await tapKey(t, 'see-ranks', settleMs: 1500);
    await tapKey(t, 'board-monthly', settleMs: 1200);
    await tapKey(t, 'tab-history', settleMs: 1300);
    await tapKey(t, 'tab-profile', settleMs: 1000);
    await tapKey(t, 'admin-link', settleMs: 1300);
    await tapKey(t, 'approve-f1', settleMs: 1200);
    debugPrint('POC_DEMO_END');
    await pumpFor(t, 500);
  });
}
