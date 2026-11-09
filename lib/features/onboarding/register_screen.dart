import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

/// One-step registration: pick a face, type a name and a mobile number. The referral
/// code is optional and checked on the spot.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const avatars = ['avatar-sara', 'avatar-grandpa', 'avatar-amir', 'avatar-grandma', 'avatar-nima', 'avatar-girl'];
  final _name = TextEditingController(text: 'سارا احمدی');
  final _phone = TextEditingController(text: '۰۹۱۲ ۳۴۵ ۶۷۸۹');
  final _ref = TextEditingController(text: 'TZB-1102');
  String _avatar = avatars.first;

  bool get _refValid => RegExp(r'^TZB-\d{4}$').hasMatch(_ref.text.trim().toUpperCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('register'),
      appBar: AppBar(backgroundColor: C.bg, surfaceTintColor: C.bg, leading: const BackButton(key: Key('back'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          const Text('ساخت پروفایل', style: T.display),
          const SizedBox(height: 4),
          const Text('فقط چند ثانیه طول می‌کشد', style: T.caption),
          const SizedBox(height: 20),
          const Text('تصویر خودت را انتخاب کن', style: T.label),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final a in avatars)
                GestureDetector(
                  key: Key('avatar-$a'),
                  onTap: () => setState(() => _avatar = a),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Avatar(a, size: 50, ring: a == _avatar ? C.accent : null),
                      if (a == _avatar)
                        const Positioned(
                          bottom: -2,
                          left: -2,
                          child: CircleAvatar(radius: 10, backgroundColor: C.accentFill, child: Icon(Icons.check, size: 14, color: Colors.white)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _field('نام', _name, key: 'name'),
          const SizedBox(height: 16),
          _field('شماره موبایل', _phone, key: 'phone', keyboard: TextInputType.phone),
          const SizedBox(height: 16),
          _field('کد معرف (اختیاری)', _ref, key: 'referral'),
          const SizedBox(height: 6),
          if (_ref.text.isNotEmpty)
            Row(children: [
              Icon(_refValid ? Icons.check_circle_outline : Icons.error_outline, size: 18, color: _refValid ? C.success : C.danger),
              const SizedBox(width: 6),
              Text(_refValid ? 'کد معرف معتبر است، ۵۰ امتیاز هدیه' : 'کد معرف درست نیست',
                  style: T.caption.copyWith(color: _refValid ? C.success : C.danger)),
            ]),
          const SizedBox(height: 32),
          PrimaryButton(
            key: const Key('register-submit'),
            label: 'ثبت‌نام و ورود',
            onPressed: _name.text.trim().isEmpty
                ? null
                : () {
                    ref.read(sessionProvider.notifier).register(name: _name.text.trim(), avatar: _avatar);
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
          ),
          const SizedBox(height: 12),
          const Center(child: Text('با ادامه، قوانین مسابقه را می‌پذیرم', style: T.caption)),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {required String key, TextInputType? keyboard}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: T.label.copyWith(color: C.text2)),
          const SizedBox(height: 6),
          TextField(key: Key('field-$key'), controller: c, keyboardType: keyboard, style: T.body, onChanged: (_) => setState(() {})),
        ],
      );
}
