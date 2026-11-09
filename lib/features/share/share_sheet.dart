import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/fa.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

String inviteLink(String code) => 'https://tizbin.app/i/$code';

/// Result + referral share. The POC copies the text; a release build hands it to the
/// system share sheet (share_plus) so it goes to any messenger.
Future<void> showShareSheet(BuildContext context, {int? score, int? correct, required String code}) {
  final text = score == null
      ? 'با کد من در تیزبین ثبت‌نام کن و ۵۰ امتیاز هدیه بگیر: ${inviteLink(code)}'
      : 'امروز در تیزبین ${fa(score)} امتیاز گرفتم (${fa(correct ?? 0)} از ۱۵). تو هم امتحان کن: ${inviteLink(code)}';
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: C.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        key: const Key('share-sheet'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: C.divider, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            const Text('اشتراک‌گذاری', style: T.title),
            const SizedBox(height: 12),
            AppCard(color: C.surfaceAlt, child: Text(text, style: T.body)),
            const SizedBox(height: 16),
            PrimaryButton(
              key: const Key('copy-share'),
              label: 'کپی متن و لینک',
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text('کپی شد', style: T.label.copyWith(color: Colors.white)), backgroundColor: C.accentFill, behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
