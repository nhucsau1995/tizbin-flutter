import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';
import 'register_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.sizeOf(context).height;
    return Scaffold(
      key: const Key('welcome'),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: Stack(
              children: [
                Image.asset('assets/images/welcome-hero.jpg', height: h * .5, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('سرگرمی سالم خانوادگی', style: T.caption.copyWith(color: C.text)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 20, color: C.accentFill),
                    const SizedBox(width: 6),
                    Text('بازی فکری تیزبین', style: T.label.copyWith(color: C.accentFill)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('هر روز ۹۰ ثانیه، ۱۵ چالش', style: T.display),
                  const SizedBox(height: 6),
                  Text('ببین، بشمار، پیدا کن و جایزه ببر', style: T.body.copyWith(color: C.text2)),
                  const SizedBox(height: 16),
                  const Wrap(spacing: 8, runSpacing: 8, children: [
                    TintChip('رایگان', icon: Icons.check_rounded),
                    TintChip('ساده', icon: Icons.bolt_rounded),
                    TintChip('برای همه سنین', icon: Icons.groups_outlined),
                  ]),
                  const Spacer(),
                  PrimaryButton(
                    key: const Key('start'),
                    label: 'شروع کنیم',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      key: const Key('login'),
                      onPressed: () => ref.read(sessionProvider.notifier).logIn(),
                      child: Text('قبلا ثبت‌نام کرده‌ام', style: T.label.copyWith(color: C.accentFill)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
