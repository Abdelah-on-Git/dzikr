import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight custom painter that draws subtle Islamic geometric corner ornaments
/// in gold (#D4AF37 at ~20% opacity) inside card borders.
class IslamicCornerPainter extends CustomPainter {
  final Color color;
  final double cornerSize;
  final double margin;

  const IslamicCornerPainter({
    this.color = const Color(0x33D4AF37),
    this.cornerSize = 18.0,
    this.margin = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < (cornerSize + margin) * 2 ||
        size.height < (cornerSize + margin) * 2) {
      return;
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Top-Right corner (RTL top start)
    _drawCorner(
        canvas, strokePaint, fillPaint, size.width - margin, margin, -1.0, 1.0);
    // Top-Left corner (RTL top end)
    _drawCorner(
        canvas, strokePaint, fillPaint, margin, margin, 1.0, 1.0);
    // Bottom-Right corner
    _drawCorner(canvas, strokePaint, fillPaint, size.width - margin,
        size.height - margin, -1.0, -1.0);
    // Bottom-Left corner
    _drawCorner(
        canvas, strokePaint, fillPaint, margin, size.height - margin, 1.0, -1.0);
  }

  void _drawCorner(
    Canvas canvas,
    Paint strokePaint,
    Paint fillPaint,
    double tx,
    double ty,
    double sx,
    double sy,
  ) {
    canvas.save();
    canvas.translate(tx, ty);
    canvas.scale(sx, sy);

    // Outer geometric framing line
    final framePath = Path();
    framePath.moveTo(0, cornerSize);
    framePath.lineTo(0, 5);
    framePath.quadraticBezierTo(0, 0, 5, 0);
    framePath.lineTo(cornerSize, 0);
    canvas.drawPath(framePath, strokePaint);

    // Inner parallel accent
    final innerPath = Path();
    innerPath.moveTo(3, cornerSize - 4);
    innerPath.lineTo(3, 6);
    innerPath.lineTo(6, 3);
    innerPath.lineTo(cornerSize - 4, 3);
    canvas.drawPath(innerPath, strokePaint);

    // Delicate 8-point Islamic star motif at corner diagonal
    final starPath = Path();
    const double centerX = 9.0;
    const double centerY = 9.0;
    const int numPoints = 8;
    const double rOuter = 3.6;
    const double rInner = 1.9;

    for (int i = 0; i < numPoints * 2; i++) {
      final double r = (i % 2 == 0) ? rOuter : rInner;
      final double angle = i * math.pi / numPoints - math.pi / 2;
      final double x = centerX + r * math.cos(angle);
      final double y = centerY + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslamicCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerSize != cornerSize ||
        oldDelegate.margin != margin;
  }
}
