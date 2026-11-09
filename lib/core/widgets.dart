import 'package:flutter/material.dart';

import 'fa.dart';
import 'theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed, this.white = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// White pill with a green label, for use on the hero gradient.
  final bool white;

  @override
  Widget build(BuildContext context) {
    final fg = white ? C.accentFill : Colors.white;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: white ? Colors.white : C.accentFill,
          foregroundColor: fg,
          disabledBackgroundColor: (white ? Colors.white : C.accentFill).withValues(alpha: .4),
          shape: const StadiumBorder(),
          textStyle: T.label.copyWith(fontSize: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: T.label.copyWith(fontSize: 16, color: fg)),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 22, color: fg)],
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.icon, this.onPressed});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: C.surface,
            foregroundColor: C.text,
            side: const BorderSide(color: C.border, width: 1.5),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: C.accentFill), const SizedBox(width: 8)],
              Text(label, style: T.label),
            ],
          ),
        ),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = C.surface, this.border});
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: C.cardShadow, border: border),
        child: child,
      );
}

class TintChip extends StatelessWidget {
  const TintChip(this.text, {super.key, this.icon, this.fg = C.accentFill, this.bg = C.accentTint});
  final String text;
  final IconData? icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            Text(text, style: T.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Star + points, top-left of every tab header.
class PointsChip extends StatelessWidget {
  const PointsChip(this.points, {super.key});
  final int points;

  @override
  Widget build(BuildContext context) => TintChip(fa(points), icon: Icons.star_rounded);
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 44, this.ring});
  final String name;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ring == null ? 0 : 3),
        decoration: BoxDecoration(shape: BoxShape.circle, color: ring ?? C.surfaceAlt),
        child: ClipOval(
          child: Image.asset('assets/images/$name.jpg', fit: BoxFit.cover, width: size, height: size,
              errorBuilder: (_, __, ___) => const ColoredBox(color: C.accentTint)),
        ),
      );
}

/// Title (or greeting) right, points chip left: the shared tab header.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, required this.points, this.leading, this.subtitle});
  final String title;
  final int points;
  final Widget? leading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: T.display),
                  if (subtitle != null) Text(subtitle!, style: T.caption),
                ],
              ),
            ),
            PointsChip(points),
          ],
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text(text, style: T.title)),
            if (trailing != null) Text(trailing!, style: T.caption),
          ],
        ),
      );
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.warn = false, this.icon});
  final String label;
  final String value;
  final bool warn;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          color: warn ? C.warningTint : C.surface,
          child: Column(
            children: [
              if (icon != null) Icon(icon, size: 20, color: warn ? C.warning : C.accentFill),
              Text(value, style: T.title.copyWith(color: warn ? C.warning : C.accentFill)),
              Text(label, style: T.caption.copyWith(color: warn ? C.warning : C.text2), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
