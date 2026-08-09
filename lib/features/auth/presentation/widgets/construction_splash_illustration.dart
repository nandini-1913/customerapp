import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ConstructionSplashIllustration extends StatelessWidget {
  const ConstructionSplashIllustration({super.key, this.width = 240, this.height = 220});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SplashPainter()),
    );
  }
}

class _SplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 240;
    final sy = size.height / 220;
    canvas.scale(sx, sy);

    final primary = AppColors.primary;
    final pc = AppColors.primaryContainer;
    final sec = AppColors.secondary;
    final outlineVariant = AppColors.outlineVariant;
    final surfaceVariant = AppColors.surfaceVariant;
    final outline = AppColors.outline;

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    canvas.drawRRect(rr(20, 190, 200, 4, 2), Paint()..color = outlineVariant);

    canvas.drawRRect(rr(90, 60, 60, 130, 4), Paint()..color = pc);
    canvas.drawRRect(rr(94, 64, 52, 122, 2), Paint()..color = primary.withValues(alpha: 0.09));

    for (final y in <double>[80, 100, 120, 140, 160]) {
      for (var col = 0; col < 3; col++) {
        final fill = col == 1 && y == 120 ? primary : primary.withValues(alpha: 0.25);
        canvas.drawRRect(rr(100.0 + col * 16, y, 10, 14, 2), Paint()..color = fill);
      }
    }

    canvas.drawRRect(rr(30, 100, 54, 90, 4), Paint()..color = surfaceVariant);
    for (final y in <double>[110, 130, 150, 165]) {
      for (var col = 0; col < 2; col++) {
        canvas.drawRRect(
          rr(38.0 + col * 22, y, 12, 14, 2),
          Paint()..color = primary.withValues(alpha: 0.19),
        );
      }
    }

    canvas.drawRRect(rr(156, 115, 54, 75, 4), Paint()..color = surfaceVariant);
    for (final y in <double>[125, 143, 161]) {
      for (var col = 0; col < 2; col++) {
        canvas.drawRRect(
          rr(163.0 + col * 22, y, 12, 14, 2),
          Paint()..color = primary.withValues(alpha: 0.19),
        );
      }
    }

    canvas.drawRRect(rr(145, 20, 4, 44, 2), Paint()..color = sec);
    canvas.drawRRect(rr(110, 18, 39, 4, 2), Paint()..color = sec);
    canvas.drawRRect(rr(110, 22, 2, 38, 1), Paint()..color = sec.withValues(alpha: 0.5));

    canvas.drawCircle(
      const Offset(52, 52),
      18,
      Paint()
        ..color = primary.withValues(alpha: 0.07)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      const Offset(52, 52),
      18,
      Paint()
        ..color = primary.withValues(alpha: 0.19)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      const Offset(52, 52),
      10,
      Paint()..color = primary.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      const Offset(52, 52),
      10,
      Paint()
        ..color = primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (final deg in [0, 45, 90, 135, 180, 225, 270, 315]) {
      final rad = deg * math.pi / 180;
      final cx = 52 + 15 * math.cos(rad);
      final cy = 52 + 15 * math.sin(rad);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rad);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-2, -3, 4, 6),
          const Radius.circular(1),
        ),
        Paint()..color = primary.withValues(alpha: 0.25),
      );
      canvas.restore();
    }

    final hex = Path()
      ..moveTo(196, 24)
      ..lineTo(210, 16)
      ..lineTo(224, 24)
      ..lineTo(224, 40)
      ..lineTo(210, 48)
      ..lineTo(196, 40)
      ..close();
    canvas.drawPath(hex, Paint()..color = sec.withValues(alpha: 0.08));
    canvas.drawPath(
      hex,
      Paint()
        ..color = sec.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(const Offset(210, 32), 5, Paint()..color = sec.withValues(alpha: 0.31));

    final diamond = Path()
      ..moveTo(36, 82)
      ..lineTo(42, 76)
      ..lineTo(48, 82)
      ..lineTo(42, 88)
      ..close();
    canvas.drawPath(diamond, Paint()..color = sec.withValues(alpha: 0.31));

    final dash = Paint()
      ..color = primary.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, const Offset(30, 130), const Offset(84, 130), dash);
    _drawDashedLine(canvas, const Offset(30, 155), const Offset(84, 155), dash);

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(16 + col * 10, 140 + row * 10),
          1.5,
          Paint()..color = primary.withValues(alpha: 0.12),
        );
      }
    }

    final measure = Paint()
      ..color = outline.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(160, 115), const Offset(160, 190), measure);
    canvas.drawLine(const Offset(157, 115), const Offset(163, 115), measure);
    canvas.drawLine(const Offset(157, 190), const Offset(163, 190), measure);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final distance = (b - a).distance;
    final direction = (b - a) / distance;
    var drawn = 0.0;
    while (drawn < distance) {
      final start = a + direction * drawn;
      final end = a + direction * math.min(drawn + dashWidth, distance);
      canvas.drawLine(start, end, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
