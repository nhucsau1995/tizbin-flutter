import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P73, checked for WCAG AA).
class C {
  static const bg = Color(0xFFF4FCF4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFE8F5E8);
  static const accent = Color(0xFF107C10);
  static const accentFill = Color(0xFF0F770F);
  static const accentPressed = Color(0xFF0E6D0E);
  static const accentTint = Color(0xFFDDF0DD);
  static const support = Color(0xFFCDB4FF);
  static const supportStrong = Color(0xFFA978FF);
  static const text = Color(0xFF0C1F0C);
  static const text2 = Color(0xFF455745);
  static const text3 = Color(0xFF5C705C);
  static const divider = Color(0xFFD3E4D3);
  static const border = Color(0xFF6DA06D);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);
  static const info = Color(0xFF0F770F);
  static const infoTint = Color(0xFFE2EFE2);

  // Game piece palette (flat 2D pieces only).
  static const red = Color(0xFFE5484D);
  static const yellow = Color(0xFFF5C518);
  static const blue = Color(0xFF3B9EFF);
  static const orange = Color(0xFFFF8A3D);
  static const pink = Color(0xFFF26FA8);

  static const heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [accentFill, accentPressed],
  );

  static const cardShadow = [
    BoxShadow(color: Color(0x0A0C1F0C), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F0C1F0C), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

/// The five type sizes from the design (display, title, body, label, caption).
class T {
  static const family = 'Vazirmatn';
  static const display = TextStyle(fontFamily: family, fontSize: 32, fontWeight: FontWeight.w800, color: C.text, height: 1.25);
  static const title = TextStyle(fontFamily: family, fontSize: 20, fontWeight: FontWeight.w700, color: C.text, height: 1.4);
  static const body = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400, color: C.text, height: 1.5);
  static const label = TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: C.text, height: 1.4);
  static const caption = TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w500, color: C.text2, height: 1.4);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: T.family,
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: C.accent, primary: C.accentFill, surface: C.surface, error: C.danger),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: T.family, bodyColor: C.text, displayColor: C.text),
    splashFactory: InkRipple.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: T.caption,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.danger)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accentFill : C.border),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
