import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/canvas_object.dart';

/// Custom painter for rendering freehand drawings
class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Adjust paint based on tool type
    switch (stroke.tool) {
      case DrawingTool.pencil:
        paint.strokeWidth = stroke.width;
        log('ger');
        break;
      case DrawingTool.marker:
        paint.strokeWidth = stroke.width * 2;
        paint.color = stroke.color.withValues(alpha: 0.7);
        break;
      case DrawingTool.eraser:
        // Eraser is handled separately in canvas controller
        return;
    }

    // Draw smooth path through points
    final path = Path();
    path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

    if (stroke.points.length == 2) {
      // Simple line for two points
      path.lineTo(stroke.points[1].dx, stroke.points[1].dy);
    } else {
      // Use quadratic bezier curves for smooth drawing
      for (int i = 1; i < stroke.points.length; i++) {
        if (i == stroke.points.length - 1) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        } else {
          final current = stroke.points[i];
          final next = stroke.points[i + 1];
          final controlPoint = Offset(
            (current.dx + next.dx) / 2,
            (current.dy + next.dy) / 2,
          );
          path.quadraticBezierTo(
            current.dx,
            current.dy,
            controlPoint.dx,
            controlPoint.dy,
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
