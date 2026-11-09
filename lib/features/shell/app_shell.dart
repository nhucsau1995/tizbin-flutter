import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../ranks/leaderboard_screen.dart';

/// The four-tab shell. In RTL the first tab (Home) sits on the right.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const tabs = [
    ('home', 'خانه', Icons.home_outlined),
    ('ranks', 'رتبه‌ها', Icons.emoji_events_outlined),
    ('history', 'تاریخچه', Icons.history_rounded),
    ('profile', 'پروفایل', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tab,
          children: const [HomeScreen(), LeaderboardScreen(), HistoryScreen(), ProfileScreen()],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: C.surface, border: Border(top: BorderSide(color: C.divider))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(children: [
              for (final (i, t) in tabs.indexed)
                Expanded(
                  child: InkWell(
                    key: Key('tab-${t.$1}'),
                    onTap: () => ref.read(tabProvider.notifier).go(i),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        decoration: BoxDecoration(color: i == tab ? C.accentTint : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                        child: Icon(t.$3, color: i == tab ? C.accentFill : C.text2),
                      ),
                      const SizedBox(height: 2),
                      Text(t.$2, style: T.caption.copyWith(color: i == tab ? C.accentFill : C.text2, fontWeight: i == tab ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
