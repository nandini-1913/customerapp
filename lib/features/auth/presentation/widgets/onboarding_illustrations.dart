import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 200,
      child: CustomPaint(
        painter: switch (index) {
          0 => _ProductsPainter(),
          1 => _ComparePainter(),
          _ => _DealersPainter(),
        },
      ),
    );
  }
}

class _ProductsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 260;
    final sy = size.height / 200;
    canvas.scale(sx, sy);

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    final paint = Paint();
    paint.color = AppColors.outlineVariant;
    canvas.drawRRect(rr(20, 155, 220, 6, 3), paint);
    canvas.drawRRect(rr(20, 55, 220, 6, 3), paint);
    canvas.drawRRect(rr(20, 55, 6, 106, 3), paint);
    canvas.drawRRect(rr(234, 55, 6, 106, 3), paint);

    paint
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rr(36, 100, 38, 55, 6), paint);
    canvas.drawRRect(
      rr(36, 100, 38, 55, 6),
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.31)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(rr(42, 110, 26, 4, 2), Paint()..color = AppColors.primary.withValues(alpha: 0.6));
    canvas.drawRRect(rr(44, 118, 22, 3, 1.5), Paint()..color = AppColors.primary.withValues(alpha: 0.3));

    final tp = TextPainter(
      text: const TextSpan(
        text: '50 KG',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(55 - tp.width / 2, 130));

    for (final x in <double>[88, 100, 112]) {
      canvas.drawRRect(rr(x, 110, 10, 45, 3), Paint()..color = const Color(0xFF94A3B8));
    }
    canvas.drawRRect(rr(86, 108, 38, 4, 2), Paint()..color = const Color(0xFFCBD5E1));

    canvas.drawRRect(
      rr(138, 108, 36, 47, 6),
      Paint()..color = AppColors.secondary.withValues(alpha: 0.19),
    );
    canvas.drawRRect(
      rr(138, 108, 36, 47, 6),
      Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(156, 108), width: 36, height: 10),
      Paint()..color = AppColors.secondary.withValues(alpha: 0.31),
    );
    canvas.drawRRect(rr(148, 94, 16, 14, 3), Paint()..color = AppColors.secondary.withValues(alpha: 0.38));
    canvas.drawCircle(const Offset(156, 130), 10, Paint()..color = AppColors.secondary.withValues(alpha: 0.25));

    canvas.drawRRect(rr(188, 118, 40, 37, 4), Paint()..color = AppColors.tertiary.withValues(alpha: 0.12));
    canvas.drawRRect(
      rr(188, 118, 40, 37, 4),
      Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.31)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawRRect(
      rr(30, 10, 200, 36, 18),
      Paint()..color = AppColors.surfaceContainer,
    );
    canvas.drawRRect(
      rr(30, 10, 200, 36, 18),
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      const Offset(55, 28),
      7,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      const Offset(60, 33),
      const Offset(64, 37),
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(rr(72, 23, 80, 8, 4), Paint()..color = AppColors.outlineVariant);
    canvas.drawRRect(rr(72, 23, 40, 8, 4), Paint()..color = AppColors.primary.withValues(alpha: 0.19));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ComparePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 260;
    final sy = size.height / 200;
    canvas.scale(sx, sy);

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    canvas.drawRRect(
      rr(16, 30, 105, 150, 14),
      Paint()..color = AppColors.surface,
    );
    canvas.drawRRect(
      rr(16, 30, 105, 150, 14),
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(
      rr(139, 30, 105, 150, 14),
      Paint()..color = AppColors.surface,
    );
    canvas.drawRRect(
      rr(139, 30, 105, 150, 14),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(rr(155, 22, 74, 18, 9), Paint()..color = AppColors.primary);
    final badge = TextPainter(
      text: const TextSpan(
        text: 'BEST MATCH',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badge.paint(canvas, Offset(192 - badge.width / 2, 27));

    canvas.drawRRect(rr(30, 48, 76, 46, 8), Paint()..color = AppColors.surfaceContainer);
    canvas.drawRRect(rr(153, 48, 76, 46, 8), Paint()..color = AppColors.primaryContainer);

    for (final x in <double>[42, 48, 54]) {
      canvas.drawRRect(rr(x, 58, 4, 26, 2), Paint()..color = const Color(0xFF94A3B8));
    }
    for (final entry in [
      [165.0, 55.0, 30.0],
      [171.0, 60.0, 25.0],
      [177.0, 52.0, 33.0],
    ]) {
      canvas.drawRRect(
        rr(entry[0], entry[1], 4, entry[2], 2),
        Paint()..color = AppColors.primary,
      );
    }

    canvas.drawCircle(
      const Offset(130, 105),
      14,
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(
      const Offset(130, 105),
      14,
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final vs = TextPainter(
      text: const TextSpan(
        text: 'VS',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.onSurface),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vs.paint(canvas, Offset(130 - vs.width / 2, 99));

    canvas.drawRRect(rr(100, 178, 60, 18, 9), Paint()..color = AppColors.primary);
    final quote = TextPainter(
      text: const TextSpan(
        text: 'Request Quote',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    quote.paint(canvas, Offset(130 - quote.width / 2, 182));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DealersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 260;
    final sy = size.height / 200;
    canvas.scale(sx, sy);

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    canvas.drawRRect(rr(10, 20, 240, 150, 16), Paint()..color = AppColors.surfaceContainer);
    canvas.drawRRect(rr(85, 20, 8, 150, 0), Paint()..color = AppColors.surface.withValues(alpha: 0.8));
    canvas.drawRRect(rr(10, 88, 240, 8, 0), Paint()..color = AppColors.surface.withValues(alpha: 0.8));

    final pins = [
      (80.0, 60.0, true),
      (160.0, 75.0, false),
      (120.0, 130.0, false),
      (200.0, 120.0, false),
      (50.0, 130.0, false),
    ];
    for (final pin in pins) {
      final active = pin.$3;
      if (active) {
        canvas.drawCircle(
          Offset(pin.$1, pin.$2),
          18,
          Paint()..color = AppColors.primary.withValues(alpha: 0.15),
        );
      }
      canvas.drawCircle(
        Offset(pin.$1, pin.$2),
        active ? 8 : 7,
        Paint()..color = active ? AppColors.primary : AppColors.surface,
      );
      if (!active) {
        canvas.drawCircle(
          Offset(pin.$1, pin.$2),
          7,
          Paint()
            ..color = AppColors.outlineVariant
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    canvas.drawCircle(const Offset(120, 95), 10, Paint()..color = AppColors.primary.withValues(alpha: 0.2));
    canvas.drawCircle(const Offset(120, 95), 5, Paint()..color = AppColors.primary);
    canvas.drawCircle(const Offset(120, 95), 3, Paint()..color = AppColors.onPrimary);

    canvas.drawRRect(rr(100, 22, 130, 52, 10), Paint()..color = AppColors.surface);
    canvas.drawRRect(rr(110, 30, 22, 22, 6), Paint()..color = AppColors.primaryContainer);
    canvas.drawRRect(rr(138, 50, 44, 16, 8), Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
