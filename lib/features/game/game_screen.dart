import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/pieces.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../domain/scoring.dart';
import '../../state/providers.dart';
import 'result_screen.dart';

/// Hosts the daily run: shared header (counter, clock ring, score), then the board for
/// the current challenge. All five games reuse the same tile and answer components.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    if (s == null) return const Scaffold(body: SizedBox());
    if (s.result != null) return const ResultScreen();
    return Scaffold(
      key: const Key('game'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _Header(s: s),
              const SizedBox(height: 16),
              Expanded(
                child: s.submitting
                    ? const _Submitting()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(key: ValueKey(s.index), child: _Board(s: s)),
                      ),
              ),
              if (!s.submitting) _Footer(feedback: s.feedback),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.s});
  final GameState s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secs = (s.remainingMs / 1000).ceil();
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text('تیزبین', style: T.label.copyWith(color: C.accentFill)),
            const Spacer(),
            OutlinedButton.icon(
              key: const Key('quit'),
              onPressed: () {
                ref.read(gameProvider.notifier).quit();
                Navigator.of(context).maybePop();
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: C.divider), shape: const StadiumBorder(), foregroundColor: C.text2),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('انصراف', style: T.caption),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TintChip('${fa(s.index + 1)} از ${fa(Rules.challenges)}'),
            const Spacer(),
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: s.remainingMs / Rules.totalMs,
                      strokeWidth: 7,
                      backgroundColor: C.surfaceAlt,
                      color: secs <= 10 ? C.warning : C.accent,
                    ),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(fa(secs), key: const Key('clock'), style: T.title.copyWith(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
                    const Text('ثانیه', style: T.caption),
                  ]),
                ],
              ),
            ),
            const Spacer(),
            PointsChip(s.runningScore),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < Rules.challenges; i++)
              Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(color: i <= s.index ? C.accent : C.surfaceAlt, borderRadius: BorderRadius.circular(99)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.feedback});
  final bool? feedback;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, text) = switch (feedback) {
      true => (C.successTint, C.success, Icons.check_circle_rounded, 'آفرین! +۱۰۰'),
      false => (C.dangerTint, C.danger, Icons.cancel_rounded, 'اشتباه بود، بعدی!'),
      null => (C.surfaceAlt, C.text2, Icons.bolt_rounded, 'هر پاسخ درست ۱۰۰ امتیاز + پاداش سرعت'),
    };
    return Container(
      key: Key('feedback-${feedback ?? 'none'}'),
      margin: const EdgeInsets.only(bottom: 16, top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 20, color: fg),
        const SizedBox(width: 8),
        Text(text, style: T.label.copyWith(color: fg)),
      ]),
    );
  }
}

class _Submitting extends StatelessWidget {
  const _Submitting();

  @override
  Widget build(BuildContext context) => Column(
        key: const Key('submitting'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: C.accent)),
          const SizedBox(height: 16),
          const Text('در حال ثبت امتیاز روی سرور...', style: T.title),
          const SizedBox(height: 4),
          Text('اگر اینترنت قطع باشد، نتیجه ذخیره و بعدا ارسال می‌شود', style: T.caption, textAlign: TextAlign.center),
        ],
      );
}

class _Board extends ConsumerWidget {
  const _Board({required this.s});
  final GameState s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = s.current;
    final game = ref.read(gameProvider.notifier);
    final (title, hint) = switch (c.type) {
      GameType.findDifferent => ('کدام تصویر فرق دارد؟', 'روی تصویر متفاوت بزن'),
      GameType.disappeared => s.memorizing
          ? ('خوب نگاه کن و به خاطر بسپار', 'یکی از تصاویر ناپدید می‌شود')
          : ('کدام تصویر ناپدید شد؟', 'یکی از گزینه‌ها را انتخاب کن'),
      GameType.count => ('چند ${pieceNames[c.pieces.first.kind]} می‌بینی؟', 'بشمار و عدد درست را بزن'),
      GameType.sameDifferent => ('این دو تصویر یکسان‌اند؟', 'با دقت به جزئیات نگاه کن'),
      GameType.match => ('جفت‌های یکسان را پیدا کن', '${fa(s.matched.length ~/ 2)} از ${fa(c.pieces.length ~/ 2)} جفت پیدا شد'),
    };
    return Column(
      key: Key('board-${c.type.name}'),
      children: [
        Text(title, style: T.title, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(hint, style: T.caption, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Expanded(
          child: switch (c.type) {
            GameType.findDifferent => _grid(3, [
                for (var i = 0; i < 9; i++)
                  _Tile(
                    key: Key(i == c.answer ? 'opt-correct' : 'opt-$i'),
                    state: s.feedback != null && s.answers.last.value == i ? s.feedback : null,
                    onTap: () => game.answer(i),
                    child: PieceView(c.pieces[i], size: 64),
                  ),
              ]),
            GameType.disappeared => _Disappeared(s: s, onPick: game.answer),
            GameType.count => _Count(s: s, onPick: game.answer),
            GameType.sameDifferent => _SameDifferent(s: s, onPick: game.answer),
            GameType.match => _Match(s: s, onTap: game.tapCard),
          },
        ),
      ],
    );
  }
}

Widget _grid(int cols, List<Widget> tiles, {double gap = 12}) => LayoutBuilder(
      builder: (context, box) {
        final rows = (tiles.length / cols).ceil();
        final size = min((box.maxWidth - gap * (cols - 1)) / cols, (box.maxHeight - gap * (rows - 1)) / rows);
        return Center(
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [for (final t in tiles) SizedBox(width: size, height: size, child: t)],
          ),
        );
      },
    );

/// The shared game tile: white card, thin border, green/red state after an answer.
class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.child, this.onTap, this.state, this.color = C.surface, this.border = C.divider});
  final Widget child;
  final VoidCallback? onTap;
  final bool? state;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final bg = state == null ? color : (state! ? C.successTint : C.dangerTint);
    final bd = state == null ? border : (state! ? C.success : C.danger);
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: bd, width: 1.5)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Center(child: child)),
    );
  }
}

class _Disappeared extends StatelessWidget {
  const _Disappeared({required this.s, required this.onPick});
  final GameState s;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final c = s.current;
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              for (var i = 0; i < c.pieces.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: !s.memorizing && i == c.hidden
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F0FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: C.supportStrong, width: 2),
                              ),
                              child: Center(child: Text('؟', style: T.display.copyWith(color: const Color(0xFF6B3FC4)))),
                            )
                          : _Tile(child: PieceView(c.pieces[i], size: 52)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!s.memorizing) ...[
          const Text('گزینه‌ها', style: T.label),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < c.options.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      height: 118,
                      child: _Tile(
                        key: Key(i == c.answer ? 'opt-correct' : 'opt-$i'),
                        state: s.feedback != null && s.answers.last.value == i ? s.feedback : null,
                        onTap: () => onPick(i),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          PieceView(c.options[i] as Piece, size: 56),
                          const SizedBox(height: 6),
                          Text(pieceNames[(c.options[i] as Piece).kind]!, style: T.caption.copyWith(color: C.text)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ] else
          Expanded(
            child: Center(
              child: SizedBox(
                width: 220,
                child: LinearProgressIndicator(
                  value: s.challengeMs / GameState.memorizeMs,
                  minHeight: 8,
                  color: C.supportStrong,
                  backgroundColor: C.surfaceAlt,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.s, required this.onPick});
  final GameState s;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final c = s.current;
    return Column(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (context, box) {
              // Scatter on a jittered grid so pieces never overlap.
              final rng = Random(c.index * 31 + 7);
              const cols = 4;
              final rows = (c.scatter.length / cols).ceil();
              final cw = box.maxWidth / cols, ch = box.maxHeight / rows;
              final piece = min(cw, ch) * .62;
              final cells = [for (var i = 0; i < cols * rows; i++) i]..shuffle(rng);
              return Stack(children: [
                for (var i = 0; i < c.scatter.length; i++)
                  Positioned(
                    left: (cells[i] % cols) * cw + (cw - piece) * rng.nextDouble(),
                    top: (cells[i] ~/ cols) * ch + (ch - piece) * rng.nextDouble(),
                    child: PieceView(c.scatter[i], size: piece),
                  ),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 16),
        for (var row = 0; row < 2; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (var k = row * 2; k < row * 2 + 2; k++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: k.isEven ? 6 : 0, right: k.isOdd ? 6 : 0),
                      child: SizedBox(
                        height: 72,
                        child: _Tile(
                          key: Key(c.options[k] == c.answer ? 'opt-correct' : 'opt-$k'),
                          border: C.border,
                          state: s.feedback != null && s.answers.last.value == c.options[k] ? s.feedback : null,
                          onTap: () => onPick(c.options[k] as int),
                          child: Text(fa(c.options[k] as int), style: T.display),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SameDifferent extends StatelessWidget {
  const _SameDifferent({required this.s, required this.onPick});
  final GameState s;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final c = s.current;
    Widget card(HouseSpec h, String label) => Expanded(
          child: Column(children: [
            AspectRatio(aspectRatio: 1, child: _Tile(child: HouseView(h, size: 130))),
            const SizedBox(height: 6),
            Text(label, style: T.caption),
          ]),
        );
    Widget answer(int v, String label, IconData icon, Color color) {
      final picked = s.feedback != null && s.answers.last.value == v;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 72,
          width: double.infinity,
          child: _Tile(
            key: Key(v == c.answer ? 'opt-correct' : 'opt-$v'),
            border: color,
            state: picked ? s.feedback : null,
            onTap: () => onPick(v),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Text(label, style: T.title.copyWith(color: color)),
            ]),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [card(c.left!, 'تصویر ۱'), const SizedBox(width: 12), card(c.right!, 'تصویر ۲')]),
        const Spacer(),
        answer(1, 'یکسان', Icons.check_circle_outline_rounded, C.success),
        answer(0, 'متفاوت', Icons.cancel_outlined, C.warning),
      ],
    );
  }
}

class _Match extends StatelessWidget {
  const _Match({required this.s, required this.onTap});
  final GameState s;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final cards = s.current.pieces;
    // Key per card: pair id + a/b, so tests and the demo can tap pairs by name.
    final seen = <Piece, int>{};
    final keys = [
      for (final p in cards) 'card-${p.kind.name}-${(seen[p] = (seen[p] ?? 0) + 1) == 1 ? 'a' : 'b'}',
    ];
    return _grid(3, [
      for (var i = 0; i < cards.length; i++)
        _MatchCard(
          key: Key(keys[i]),
          piece: cards[i],
          open: s.flipped.contains(i) || s.matched.contains(i),
          matched: s.matched.contains(i),
          wrong: s.flipped.length == 2 && s.flipped.contains(i),
          onTap: () => onTap(i),
        ),
    ]);
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({super.key, required this.piece, required this.open, required this.matched, required this.wrong, required this.onTap});
  final Piece piece;
  final bool open;
  final bool matched;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!open) {
      return Material(
        color: C.support,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const Center(child: Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 34)),
        ),
      );
    }
    return Stack(children: [
      Positioned.fill(
        child: _Tile(
          color: matched ? C.successTint : C.surface,
          border: matched ? C.success : (wrong ? C.danger : C.accent),
          child: PieceView(piece, size: 60),
        ),
      ),
      if (matched) const Positioned(top: 6, left: 6, child: Icon(Icons.check_circle_rounded, size: 18, color: C.success)),
    ]);
  }
}
