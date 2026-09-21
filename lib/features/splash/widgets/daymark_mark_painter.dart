import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Draws Daymark's signature glyph: a single tapered stroke that settles
/// into a solid point, like a pen marking a day. Not a logo lockup — the
/// mark itself is the entire brand moment, so this painter renders three
/// phases of one continuous gesture rather than a static icon:
///
/// 1. The stroke draws itself in along its own path length.
/// 2. The stroke's end blooms into a filled point.
/// 3. A soft ring expands outward from that point and fades — the "mark
///    landing" beat — then holds.
///
/// [strokeProgress], [pointProgress], and [ringProgress] are independent
/// 0..1 values so the caller can stagger them from one AnimationController.
class DaymarkMarkPainter extends CustomPainter {
  DaymarkMarkPainter({
    required this.strokeProgress,
    required this.pointProgress,
    required this.ringProgress,
    required this.strokeColorStart,
    required this.strokeColorEnd,
  });

  final double strokeProgress;
  final double pointProgress;
  final double ringProgress;
  final Color strokeColorStart;
  final Color strokeColorEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final endTangent = metric.getTangentForOffset(metric.length);
    final endPoint = endTangent?.position ?? Offset(size.width * 0.5, size.height * 0.5);

    if (strokeProgress > 0) {
      final visible = metric.extractPath(0, metric.length * strokeProgress);
      final gradient = ui.Gradient.linear(
        Offset(size.width * 0.15, size.height * 0.15),
        Offset(size.width * 0.85, size.height * 0.85),
        [strokeColorStart, strokeColorEnd],
      );
      final paint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(visible, paint);
    }

    if (ringProgress > 0) {
      final ringPaint = Paint()
        ..color = strokeColorEnd.withValues(alpha: (1 - ringProgress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(endPoint, 6 + ringProgress * 22, ringPaint);
    }

    if (pointProgress > 0) {
      final dotPaint = Paint()
        ..color = strokeColorEnd
        ..style = PaintingStyle.fill;
      canvas.drawCircle(endPoint, 5 * pointProgress, dotPaint);

      final glowPaint = Paint()
        ..color = strokeColorEnd.withValues(alpha: 0.35 * pointProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(endPoint, 10 * pointProgress, glowPaint);
    }
  }

  /// One continuous asymmetric swoosh, tuned to a 120x120 canvas and scaled
  /// to whatever [size] is given. It reads as a mark being made, not as a
  /// checkmark or any recognizable icon.
  Path _buildPath(Size size) {
    final w = size.width / 120;
    final h = size.height / 120;
    return Path()
      ..moveTo(28 * w, 34 * h)
      ..cubicTo(20 * w, 58 * h, 34 * w, 82 * h, 58 * w, 88 * h)
      ..cubicTo(80 * w, 93 * h, 96 * w, 74 * h, 90 * w, 52 * h);
  }

  @override
  bool shouldRepaint(covariant DaymarkMarkPainter oldDelegate) {
    return oldDelegate.strokeProgress != strokeProgress ||
        oldDelegate.pointProgress != pointProgress ||
        oldDelegate.ringProgress != ringProgress;
  }
}
