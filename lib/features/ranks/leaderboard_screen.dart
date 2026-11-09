import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(boardModeProvider);
    final rows = ref.board();
    final me = ref.watch(sessionProvider)!;
    final mine = rows.where((r) => r.playerId == me.id).firstOrNull;
    final top = rows.take(3).toList();
    return Column(
      key: const Key('leaderboard'),
      children: [
        TabHeader(title: 'رتبه‌ها', points: ref.totalPoints()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              _Segment(mode: mode, onChanged: ref.read(boardModeProvider.notifier).set),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  mode == BoardMode.daily ? 'رتبه بر اساس پاسخ درست، سپس سرعت' : 'مجموع ۱۵ امتیاز بهتر هر نفر در ۳۰ روز اخیر',
                  style: T.caption,
                ),
              ),
              const SizedBox(height: 16),
              if (top.length == 3) _Podium(top: top),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(children: [
                  for (final r in rows.skip(3).take(5)) ...[
                    _Row(r: r, monthly: mode == BoardMode.monthly),
                    if (r != rows.skip(3).take(5).last) const Divider(height: 1, color: C.surfaceAlt),
                  ],
                ]),
              ),
            ],
          ),
        ),
        if (mine != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              key: const Key('my-rank'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
              child: _Row(r: mine, monthly: mode == BoardMode.monthly, me: true),
            ),
          ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.mode, required this.onChanged});
  final BoardMode mode;
  final void Function(BoardMode) onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: C.surfaceAlt, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final (m, label) in [(BoardMode.daily, 'روزانه'), (BoardMode.monthly, 'ماهانه')])
            Expanded(
              child: GestureDetector(
                key: Key('board-${m.name}'),
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: m == mode ? C.accentFill : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                  child: Text(label, style: T.label.copyWith(color: m == mode ? Colors.white : C.text2)),
                ),
              ),
            ),
        ]),
      );
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top});
  final List<LeaderRow> top;

  @override
  Widget build(BuildContext context) {
    Widget place(LeaderRow r, double block, double avatar, Color color, String label) => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (r.rank == 1) const Icon(Icons.workspace_premium_rounded, color: C.orange, size: 28),
              Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
                Avatar(r.avatar, size: avatar, ring: r.rank == 1 ? C.accent : C.surface),
                Positioned(
                  bottom: -10,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: r.rank == 1 ? C.accentFill : C.surface,
                    child: Text(fa(r.rank), style: T.caption.copyWith(color: r.rank == 1 ? Colors.white : C.accentFill, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Text(r.name, style: T.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(fa(r.score), style: T.label.copyWith(color: C.accentFill)),
              const SizedBox(height: 8),
              Container(
                height: block,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                alignment: Alignment.center,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(fa(r.rank), style: T.display.copyWith(color: r.rank == 1 ? const Color(0xFF4A2A8C) : C.accentFill)),
                  Text(label, style: T.caption.copyWith(color: r.rank == 1 ? const Color(0xFF4A2A8C) : C.text2)),
                ]),
              ),
            ],
          ),
        );
    return SizedBox(
      height: 320,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        place(top[1], 96, 64, C.accentTint, 'مقام دوم'),
        place(top[0], 128, 84, C.support, 'قهرمان'),
        place(top[2], 80, 64, C.accentTint, 'مقام سوم'),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.r, required this.monthly, this.me = false});
  final LeaderRow r;
  final bool monthly;
  final bool me;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(width: 32, child: Text(fa(r.rank), style: T.label.copyWith(color: me ? C.accentFill : C.text2), textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          Avatar(r.avatar, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(r.name, style: T.label, overflow: TextOverflow.ellipsis)),
                if (me) ...[const SizedBox(width: 6), const TintChip('شما', fg: Colors.white, bg: C.accentFill)],
              ]),
              Text(
                monthly ? '${fa(r.correct)} پاسخ درست' : '${fa(r.correct)}/۱۵ درست • ${fa((r.timeMs / 1000).round())} ثانیه',
                style: T.caption,
              ),
            ]),
          ),
          Text(fa(r.score), style: T.title.copyWith(color: C.accentFill)),
        ]),
      );
}
