import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

/// Basic admin: users and today's plays, flagged scores to approve or reject, and the
/// manual prize record. Payouts stay disabled until legal and payment compliance is done.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  static const reasons = {'too-fast': 'خیلی سریع', 'multi-account': 'چند حساب'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverProvider);
    final flags = ref.watch(flagsProvider);
    final today = ref.watch(todayProvider);
    final todayCount = server.daily(today).length;
    final open = flags.where((f) => f.status == FlagStatus.pending).length;
    final recent = server.daily(today).take(4).toList();
    return Scaffold(
      key: const Key('admin'),
      appBar: AppBar(
        backgroundColor: C.bg,
        surfaceTintColor: C.bg,
        leading: const BackButton(key: Key('back')),
        title: const Text('پنل مدیریت', style: T.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(children: [
            StatCard(label: 'کاربران', value: fa(server.data.players.length), icon: Icons.people_outline),
            const SizedBox(width: 10),
            StatCard(label: 'بازی امروز', value: fa(todayCount), icon: Icons.sports_esports_outlined),
            const SizedBox(width: 10),
            StatCard(label: 'مشکوک', value: fa(open), warn: open > 0, icon: Icons.warning_amber_rounded),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.infoTint, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: C.info),
              const SizedBox(width: 8),
              Expanded(child: Text('پرداخت خودکار جایزه غیرفعال است تا تایید حقوقی', style: T.label.copyWith(color: C.info))),
            ]),
          ),
          const SectionTitle('امتیازهای مشکوک'),
          for (final f in flags) ...[
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(f.userLabel, style: T.label.copyWith(fontSize: 16))),
                  TintChip(reasons[f.reason] ?? f.reason, icon: Icons.warning_amber_rounded, fg: C.warning, bg: C.warningTint),
                ]),
                const SizedBox(height: 4),
                Text(f.detail, style: T.caption),
                const SizedBox(height: 12),
                if (f.status == FlagStatus.pending)
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        key: Key('reject-${f.id}'),
                        onPressed: () => ref.read(flagsProvider.notifier).decide(f.id, FlagStatus.rejected),
                        style: OutlinedButton.styleFrom(foregroundColor: C.danger, side: const BorderSide(color: C.danger), shape: const StadiumBorder(), minimumSize: const Size.fromHeight(44)),
                        child: const Text('رد امتیاز', style: T.label),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: Key('approve-${f.id}'),
                        onPressed: () => ref.read(flagsProvider.notifier).decide(f.id, FlagStatus.approved),
                        style: FilledButton.styleFrom(backgroundColor: C.accentFill, shape: const StadiumBorder(), minimumSize: const Size.fromHeight(44)),
                        child: Text('تایید', style: T.label.copyWith(color: Colors.white)),
                      ),
                    ),
                  ])
                else
                  TintChip(
                    f.status == FlagStatus.approved ? 'تایید شد' : 'رد شد',
                    fg: f.status == FlagStatus.approved ? C.success : C.danger,
                    bg: f.status == FlagStatus.approved ? C.successTint : C.dangerTint,
                  ),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          const SectionTitle('ثبت جوایز (دستی)'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (i, p) in server.data.prizes.indexed) ...[
                if (i > 0) const Divider(height: 1, color: C.surfaceAlt),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    Expanded(child: Text('${p.month} - ${p.place} - ${p.winner}', style: T.label)),
                    TintChip(
                      p.recorded ? 'ثبت شد' : 'در انتظار تایید',
                      fg: p.recorded ? C.success : C.warning,
                      bg: p.recorded ? C.successTint : C.warningTint,
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          const SectionTitle('بازیکنان امروز'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final r in recent)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Avatar(r.avatar, size: 40),
                  title: Text(r.name, style: T.label),
                  subtitle: Text('${fa(r.correct)}/۱۵ • ${fa((r.timeMs / 1000).round())} ثانیه', style: T.caption),
                  trailing: Text(fa(r.score), style: T.label.copyWith(color: C.accentFill)),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
