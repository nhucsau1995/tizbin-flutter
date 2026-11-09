import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tizbin/domain/models.dart';
import 'package:tizbin/state/providers.dart';

/// Fixed-time pumps instead of pumpAndSettle: the game clock ring never settles.
Future<void> pumpFor(WidgetTester t, [int ms = 600]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int timeoutMs = 30000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (f.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) throw StateError('Timed out waiting for $f');
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapKey(WidgetTester t, String key, {int settleMs = 900}) async {
  final f = find.byKey(Key(key));
  await waitFor(t, f);
  await t.ensureVisible(f.last);
  await pumpFor(t, 250);
  await t.tap(f.last);
  await pumpFor(t, settleMs);
}

ProviderContainer containerOf(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MaterialApp)));

/// Plays the current challenge. [wrong] taps a wrong option on purpose.
Future<void> playOne(WidgetTester t, {int paceMs = 500, bool wrong = false}) async {
  final s = containerOf(t).read(gameProvider)!;
  final c = s.current;
  final before = s.answers.length;
  await waitFor(t, find.byKey(Key('board-${c.type.name}')));
  if (c.type == GameType.disappeared) {
    await waitFor(t, find.text('کدام تصویر ناپدید شد؟'), timeoutMs: 5000);
  }
  await pumpFor(t, paceMs);
  if (c.type == GameType.match) {
    for (final p in c.pieces.toSet()) {
      await tapKey(t, 'card-${p.kind.name}-a', settleMs: 250);
      await tapKey(t, 'card-${p.kind.name}-b', settleMs: 350);
    }
  } else if (wrong) {
    final opts = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('opt-') && (w.key as ValueKey<String>).value != 'opt-correct');
    await t.tap(opts.first);
    await pumpFor(t, 200);
  } else {
    await tapKey(t, 'opt-correct', settleMs: 200);
  }
  // The answer must have registered; then wait for the next board (or the end of the run).
  final end = DateTime.now().add(const Duration(seconds: 10));
  while (true) {
    final now = containerOf(t).read(gameProvider);
    if (now == null || now.finished || (now.answers.length > before && now.feedback == null)) break;
    if (DateTime.now().isAfter(end)) throw StateError('Answer to challenge ${c.index} did not register');
    await t.pump(const Duration(milliseconds: 50));
  }
}

Future<void> register(WidgetTester t, {int settleMs = 900}) async {
  await tapKey(t, 'start', settleMs: settleMs);
  await tapKey(t, 'register-submit', settleMs: settleMs);
  await waitFor(t, find.byKey(const Key('start-game')));
}
