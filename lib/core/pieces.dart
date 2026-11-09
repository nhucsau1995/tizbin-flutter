import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'theme.dart';

Color pieceColor(PieceColor c) => switch (c) {
      PieceColor.red => C.red,
      PieceColor.green => C.accent,
      PieceColor.yellow => C.yellow,
      PieceColor.blue => C.blue,
      PieceColor.orange => C.orange,
      PieceColor.lavender => C.support,
      PieceColor.pink => C.pink,
    };

const pieceNames = {
  PieceKind.apple: 'سیب',
  PieceKind.star: 'ستاره',
  PieceKind.heart: 'قلب',
  PieceKind.ball: 'توپ',
  PieceKind.sun: 'خورشید',
  PieceKind.flower: 'گل',
  PieceKind.fish: 'ماهی',
  PieceKind.house: 'خانه',
  PieceKind.duck: 'اردک',
  PieceKind.car: 'ماشین',
  PieceKind.banana: 'موز',
  PieceKind.cat: 'گربه',
};

/// A flat 2D game piece drawn with a few shapes: no image files, no network,
/// sharp at any size and cheap on low-end phones.
class PieceView extends StatelessWidget {
  const PieceView(this.piece, {super.key, this.size = 56});
  final Piece piece;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _PiecePainter(piece)),
      );
}

class _PiecePainter extends CustomPainter {
  _PiecePainter(this.piece);
  final Piece piece;

  static const stem = Color(0xFF7A4A21);
  static const leaf = Color(0xFF2E9B3A);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final p = Paint()..color = pieceColor(piece.color);
    final dark = Paint()..color = const Color(0xFF0C1F0C);
    final white = Paint()..color = Colors.white;
    switch (piece.kind) {
      case PieceKind.apple:
        canvas.drawOval(Rect.fromLTWH(w * .12, w * .28, w * .42, w * .62), p);
        canvas.drawOval(Rect.fromLTWH(w * .46, w * .28, w * .42, w * .62), p);
        canvas.drawLine(Offset(w * .5, w * .34), Offset(w * .44, w * .12), Paint()..color = stem..strokeWidth = w * .06..strokeCap = StrokeCap.round);
        final l = Path()
          ..moveTo(w * .52, w * .22)
          ..quadraticBezierTo(w * .62, w * .06, w * .76, w * .14)
          ..quadraticBezierTo(w * .68, w * .28, w * .52, w * .22);
        canvas.drawPath(l, Paint()..color = piece.color == PieceColor.green ? const Color(0xFF7BC67B) : leaf);
      case PieceKind.star:
        canvas.drawPath(_star(Offset(w / 2, w * .53), w * .46, w * .2, 5), p);
      case PieceKind.heart:
        final h = Path()
          ..moveTo(w * .5, w * .86)
          ..cubicTo(w * .02, w * .52, w * .14, w * .1, w * .5, w * .3)
          ..cubicTo(w * .86, w * .1, w * .98, w * .52, w * .5, w * .86);
        canvas.drawPath(h, p);
      case PieceKind.ball:
        canvas.drawCircle(Offset(w / 2, w / 2), w * .4, p);
        final band = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = w * .07;
        canvas.drawArc(Rect.fromCircle(center: Offset(w / 2, w / 2), radius: w * .4), -.6, 1.2, false, band);
        canvas.drawArc(Rect.fromCircle(center: Offset(w / 2, w / 2), radius: w * .4), pi - .6, 1.2, false, band);
      case PieceKind.sun:
        final ray = Paint()..color = p.color..strokeWidth = w * .07..strokeCap = StrokeCap.round;
        for (var i = 0; i < 8; i++) {
          final a = i * pi / 4;
          canvas.drawLine(Offset(w / 2 + cos(a) * w * .32, w / 2 + sin(a) * w * .32), Offset(w / 2 + cos(a) * w * .45, w / 2 + sin(a) * w * .45), ray);
        }
        canvas.drawCircle(Offset(w / 2, w / 2), w * .24, p);
      case PieceKind.flower:
        for (var i = 0; i < 6; i++) {
          final a = i * pi / 3;
          canvas.drawCircle(Offset(w / 2 + cos(a) * w * .2, w * .42 + sin(a) * w * .2), w * .15, p);
        }
        canvas.drawCircle(Offset(w / 2, w * .42), w * .11, Paint()..color = C.yellow);
        canvas.drawLine(Offset(w / 2, w * .62), Offset(w / 2, w * .95), Paint()..color = leaf..strokeWidth = w * .06);
      case PieceKind.fish:
        canvas.drawOval(Rect.fromLTWH(w * .1, w * .3, w * .62, w * .4), p);
        final tail = Path()
          ..moveTo(w * .66, w * .5)
          ..lineTo(w * .92, w * .3)
          ..lineTo(w * .92, w * .7)
          ..close();
        canvas.drawPath(tail, p);
        canvas.drawCircle(Offset(w * .26, w * .46), w * .05, dark);
      case PieceKind.house:
        canvas.drawRect(Rect.fromLTWH(w * .2, w * .45, w * .6, w * .45), Paint()..color = C.orange);
        final roof = Path()
          ..moveTo(w * .12, w * .48)
          ..lineTo(w * .5, w * .14)
          ..lineTo(w * .88, w * .48)
          ..close();
        canvas.drawPath(roof, Paint()..color = C.red);
      case PieceKind.duck:
        canvas.drawOval(Rect.fromLTWH(w * .12, w * .45, w * .7, w * .4), p);
        canvas.drawCircle(Offset(w * .3, w * .38), w * .17, p);
        final beak = Path()
          ..moveTo(w * .14, w * .36)
          ..lineTo(w * .0, w * .42)
          ..lineTo(w * .14, w * .46)
          ..close();
        canvas.drawPath(beak, Paint()..color = C.orange.withValues(alpha: 1));
        canvas.drawCircle(Offset(w * .28, w * .34), w * .035, dark);
      case PieceKind.car:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .06, w * .42, w * .88, w * .28), Radius.circular(w * .08)), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .24, w * .24, w * .5, w * .22), Radius.circular(w * .08)), p);
        canvas.drawRect(Rect.fromLTWH(w * .3, w * .29, w * .17, w * .13), white);
        canvas.drawRect(Rect.fromLTWH(w * .52, w * .29, w * .17, w * .13), white);
        canvas.drawCircle(Offset(w * .28, w * .72), w * .1, dark);
        canvas.drawCircle(Offset(w * .72, w * .72), w * .1, dark);
      case PieceKind.banana:
        final b = Path()
          ..moveTo(w * .14, w * .3)
          ..quadraticBezierTo(w * .2, w * .88, w * .86, w * .7)
          ..quadraticBezierTo(w * .4, w * .66, w * .3, w * .26)
          ..close();
        canvas.drawPath(b, p);
        canvas.drawLine(Offset(w * .14, w * .3), Offset(w * .2, w * .18), Paint()..color = stem..strokeWidth = w * .06..strokeCap = StrokeCap.round);
      case PieceKind.cat:
        canvas.drawCircle(Offset(w / 2, w * .56), w * .32, p);
        canvas.drawPath(Path()..moveTo(w * .22, w * .4)..lineTo(w * .26, w * .1)..lineTo(w * .46, w * .28)..close(), p);
        canvas.drawPath(Path()..moveTo(w * .78, w * .4)..lineTo(w * .74, w * .1)..lineTo(w * .54, w * .28)..close(), p);
        canvas.drawCircle(Offset(w * .38, w * .52), w * .045, dark);
        canvas.drawCircle(Offset(w * .62, w * .52), w * .045, dark);
        canvas.drawCircle(Offset(w * .5, w * .64), w * .04, Paint()..color = C.pink);
    }
  }

  Path _star(Offset c, double r1, double r2, int n) {
    final path = Path();
    for (var i = 0; i < n * 2; i++) {
      final r = i.isEven ? r1 : r2;
      final a = -pi / 2 + i * pi / n;
      final pt = Offset(c.dx + cos(a) * r, c.dy + sin(a) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}

/// The house drawing for "same or different": two windows and a door whose colors vary.
class HouseView extends StatelessWidget {
  const HouseView(this.spec, {super.key, this.size = 120});
  final HouseSpec spec;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _HousePainter(spec)));
}

class _HousePainter extends CustomPainter {
  _HousePainter(this.spec);
  final HouseSpec spec;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    canvas.drawRect(Rect.fromLTWH(w * .66, w * .16, w * .1, w * .2), Paint()..color = const Color(0xFF8A5A3B));
    canvas.drawRect(Rect.fromLTWH(w * .16, w * .46, w * .68, w * .46), Paint()..color = C.orange);
    canvas.drawPath(Path()..moveTo(w * .08, w * .5)..lineTo(w * .5, w * .12)..lineTo(w * .92, w * .5)..close(), Paint()..color = C.red);
    canvas.drawRect(Rect.fromLTWH(w * .24, w * .56, w * .16, w * .14), Paint()..color = pieceColor(spec.windowLeft));
    canvas.drawRect(Rect.fromLTWH(w * .6, w * .56, w * .16, w * .14), Paint()..color = pieceColor(spec.windowRight));
    canvas.drawRect(Rect.fromLTWH(w * .43, w * .64, w * .14, w * .28), Paint()..color = pieceColor(spec.door));
  }

  @override
  bool shouldRepaint(_HousePainter old) => old.spec != spec;
}
