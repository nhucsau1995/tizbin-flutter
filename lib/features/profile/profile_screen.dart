import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';
import '../admin/admin_screen.dart';
import '../share/share_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(sessionProvider)!;
    final prefs = ref.watch(prefsProvider);
    final history = ref.history();
    final server = ref.watch(serverProvider);
    final bestRank = history.isEmpty
        ? 0
        : history.map((r) => server.dailyRank(me.id, r.day)).where((r) => r > 0).fold<int>(9999, (a, b) => a < b ? a : b);
    return ListView(
      key: const Key('profile'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        TabHeader(title: 'پروفایل', points: ref.totalPoints()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 8),
            Avatar(me.avatar, size: 112, ring: C.accent),
            const SizedBox(height: 10),
            Text(me.name, style: T.title),
            Text(me.phone, style: T.caption),
            const SizedBox(height: 16),
            Row(children: [
              StatCard(label: 'امتیاز کل', value: fa(ref.totalPoints())),
              const SizedBox(width: 10),
              const StatCard(label: 'دعوت‌ها', value: '۵'),
              const SizedBox(width: 10),
              StatCard(label: 'بهترین رتبه', value: bestRank == 9999 || bestRank == 0 ? '-' : fa(bestRank)),
            ]),
            const SizedBox(height: 16),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.card_giftcard_rounded, color: C.accentFill),
                  SizedBox(width: 8),
                  Text('لینک دعوت تو', style: T.label),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: C.surfaceAlt, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
                  child: Row(children: [
                    Expanded(child: Text(inviteLink(me.referralCode), style: T.label, textDirection: TextDirection.ltr)),
                    const Icon(Icons.copy_rounded, size: 20, color: C.accentFill),
                  ]),
                ),
                const SizedBox(height: 8),
                const Text('هر دوستی که با کد تو بیاید ۵۰ امتیاز هدیه', style: T.caption),
                const SizedBox(height: 12),
                PrimaryButton(
                  key: const Key('share-invite'),
                  label: 'اشتراک‌گذاری لینک',
                  icon: Icons.share_outlined,
                  onPressed: () => showShareSheet(context, code: me.referralCode),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(children: [
                SwitchListTile(
                  value: prefs.sound,
                  onChanged: ref.read(prefsProvider.notifier).sound,
                  secondary: const Icon(Icons.volume_up_outlined, color: C.text2),
                  title: const Text('صدا', style: T.label),
                ),
                const Divider(height: 1, color: C.surfaceAlt),
                SwitchListTile(
                  value: prefs.largeText,
                  onChanged: ref.read(prefsProvider.notifier).largeText,
                  secondary: const Icon(Icons.text_fields_rounded, color: C.text2),
                  title: const Text('متن بزرگ', style: T.label),
                ),
                const Divider(height: 1, color: C.surfaceAlt),
                const ListTile(
                  leading: Icon(Icons.menu_book_outlined, color: C.text2),
                  title: Text('قوانین مسابقه', style: T.label),
                  subtitle: Text('۱۵ چالش، ۹۰ ثانیه، یک تلاش رسمی در روز', style: T.caption),
                  trailing: Icon(Icons.chevron_left_rounded),
                ),
                const Divider(height: 1, color: C.surfaceAlt),
                ListTile(
                  key: const Key('admin-link'),
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: C.text2),
                  title: const Text('پنل مدیریت', style: T.label),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminScreen())),
                ),
                const Divider(height: 1, color: C.surfaceAlt),
                ListTile(
                  key: const Key('logout'),
                  leading: const Icon(Icons.logout_rounded, color: C.danger),
                  title: Text('خروج', style: T.label.copyWith(color: C.danger)),
                  onTap: () {
                    ref.read(tabProvider.notifier).go(0);
                    ref.read(sessionProvider.notifier).logOut();
                  },
                ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}
