import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for canvas transformations and coordinate conversions

/// Transform a 2D point using a Matrix4 transformation matrix
/// Matrix4 uses column-major order
Offset _transformPointWithMatrix(Offset point, Matrix4 matrix) {
  // For 2D transformations: result = matrix * [x, y, 0, 1]^T
  // Extract x and y components from the transformed point
  final x =
      matrix.entry(0, 0) * point.dx +
      matrix.entry(0, 1) * point.dy +
      matrix.entry(0, 3);
  final y =
      matrix.entry(1, 0) * point.dx +
      matrix.entry(1, 1) * point.dy +
      matrix.entry(1, 3);
  return Offset(x, y);
}

/// Convert a point from screen coordinates to canvas coordinates
///
/// The transformation matrix from InteractiveViewer needs to be inverted
/// to convert screen coordinates back to canvas coordinates.
Offset screenToCanvas(Offset screenPoint, Matrix4 transformation) {
  final inverted = Matrix4.inverted(transformation);
  return _transformPointWithMatrix(screenPoint, inverted);
}

/// Convert a point from canvas coordinates to screen coordinates
Offset canvasToScreen(Offset canvasPoint, Matrix4 transformation) {
  return _transformPointWithMatrix(canvasPoint, transformation);
}

/// Get the scale factor from a transformation matrix
double getScale(Matrix4 matrix) {
  return math.sqrt(
    matrix.entry(0, 0) * matrix.entry(0, 0) +
        matrix.entry(1, 0) * matrix.entry(1, 0),
  );
}

/// Get the translation from a transformation matrix
Offset getTranslation(Matrix4 matrix) {
  return Offset(matrix.entry(0, 3), matrix.entry(1, 3));
}

/// Calculate distance between two points
double distance(Offset a, Offset b) {
  final dx = a.dx - b.dx;
  final dy = a.dy - b.dy;
  return math.sqrt(dx * dx + dy * dy);
}

/// Calculate angle between two points (in radians)
double angleBetween(Offset a, Offset b) {
  return math.atan2(b.dy - a.dy, b.dx - a.dx);
}

/// Rotate a point around a center by an angle (in radians)
Offset rotatePoint(Offset point, Offset center, double angle) {
  final dx = point.dx - center.dx;
  final dy = point.dy - center.dy;
  final cosA = math.cos(angle);
  final sinA = math.sin(angle);
  return Offset(
    center.dx + dx * cosA - dy * sinA,
    center.dy + dx * sinA + dy * cosA,
  );
}

/// Apply transformation to a point
Offset transformPoint(
  Offset point,
  Offset position,
  double scale,
  double rotation,
) {
  // Translate to origin
  var result = point - position;

  // Rotate
  if (rotation != 0) {
    final cosR = math.cos(rotation);
    final sinR = math.sin(rotation);
    final x = result.dx;
    final y = result.dy;
    result = Offset(x * cosR - y * sinR, x * sinR + y * cosR);
  }

  // Scale
  result = Offset(result.dx * scale, result.dy * scale);

  // Translate back
  return result + position;
}

/// Check if a point is within a rotated rectangle
bool pointInRotatedRect(
  Offset point,
  Offset rectCenter,
  double width,
  double height,
  double rotation,
) {
  // Translate point to rectangle's local coordinate system
  final dx = point.dx - rectCenter.dx;
  final dy = point.dy - rectCenter.dy;

  // Rotate point back by negative rotation
  final cosR = math.cos(-rotation);
  final sinR = math.sin(-rotation);
  final localX = dx * cosR - dy * sinR;
  final localY = dx * sinR + dy * cosR;

  // Check if point is within unrotated rectangle bounds
  return localX.abs() <= width / 2 && localY.abs() <= height / 2;
}
