import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Base class for all objects on the canvas
abstract class CanvasObject {
  final String id;
  final Offset position;
  final double scale;
  final double rotation; // in radians
  final int zIndex;
  final bool isSelected;

  const CanvasObject({
    required this.id,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.zIndex,
    this.isSelected = false,
  });

  /// Create a copy with updated properties
  CanvasObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
  });

  /// Get the bounding box of this object in canvas coordinates
  Rect getBounds();

  /// Check if a point (in canvas coordinates) is within this object
  bool containsPoint(Offset point);

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson();

  /// Create from JSON
  static CanvasObject fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'text':
        return TextObject.fromJson(json);
      case 'image':
        return ImageObject.fromJson(json);
      case 'pdf':
        return PdfObject.fromJson(json);
      case 'shape':
        return ShapeObject.fromJson(json);
      case 'drawing':
        return DrawingObject.fromJson(json);
      default:
        throw Exception('Unknown object type: $type');
    }
  }
}

/// Text box object
class TextObject extends CanvasObject {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double width;
  final double height;

  const TextObject({
    required super.id,
    required super.position,
    super.scale = 1.0,
    super.rotation = 0.0,
    required super.zIndex,
    super.isSelected = false,
    required this.text,
    this.fontSize = 24.0,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.width = 200.0,
    this.height = 100.0,
  });

  @override
  TextObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
    String? text,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? width,
    double? height,
  }) {
    return TextObject(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isSelected: isSelected ?? this.isSelected,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Rect getBounds() {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      width * scale,
      height * scale,
    );
  }

  @override
  bool containsPoint(Offset point) {
    final bounds = getBounds();
    // Account for rotation by checking if point is in rotated bounds
    final center = bounds.center;
    final relativePoint = point - center;
    final rotatedPoint = Offset(
      relativePoint.dx * math.cos(-rotation) -
          relativePoint.dy * math.sin(-rotation),
      relativePoint.dx * math.sin(-rotation) +
          relativePoint.dy * math.cos(-rotation),
    );
    final unrotatedBounds = Rect.fromCenter(
      center: Offset.zero,
      width: bounds.width,
      height: bounds.height,
    );
    return unrotatedBounds.contains(rotatedPoint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'text': text,
      'fontSize': fontSize,
      'color': color.toARGB32(),
      'fontWeight': fontWeight.index,
      'width': width,
      'height': height,
    };
  }

  static TextObject fromJson(Map<String, dynamic> json) {
    return TextObject(
      id: json['id'] as String,
      position: Offset(
        (json['position'] as Map)['x'] as double,
        (json['position'] as Map)['y'] as double,
      ),
      scale: json['scale'] as double? ?? 1.0,
      rotation: json['rotation'] as double? ?? 0.0,
      zIndex: json['zIndex'] as int,
      text: json['text'] as String,
      fontSize: json['fontSize'] as double? ?? 24.0,
      color: Color(json['color'] as int),
      fontWeight: FontWeight.values[json['fontWeight'] as int],
      width: json['width'] as double? ?? 200.0,
      height: json['height'] as double? ?? 100.0,
    );
  }
}

/// Image object
class ImageObject extends CanvasObject {
  final ui.Image image;
  final double width;
  final double height;

  const ImageObject({
    required super.id,
    required super.position,
    super.scale = 1.0,
    super.rotation = 0.0,
    required super.zIndex,
    super.isSelected = false,
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  ImageObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
    ui.Image? image,
    double? width,
    double? height,
  }) {
    return ImageObject(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isSelected: isSelected ?? this.isSelected,
      image: image ?? this.image,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Rect getBounds() {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      width * scale,
      height * scale,
    );
  }

  @override
  bool containsPoint(Offset point) {
    return getBounds().contains(point);
  }

  @override
  Map<String, dynamic> toJson() {
    // Note: Images are stored as base64 or file paths in real implementation
    return {
      'type': 'image',
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'width': width,
      'height': height,
      'imagePath': '', // Should be set when loading
    };
  }

  static ImageObject fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('ImageObject.fromJson requires image loading');
  }
}

/// PDF page object (rendered as image)
class PdfObject extends CanvasObject {
  final ui.Image pdfPageImage;
  final int pageNumber;
  final double width;
  final double height;

  const PdfObject({
    required super.id,
    required super.position,
    super.scale = 1.0,
    super.rotation = 0.0,
    required super.zIndex,
    super.isSelected = false,
    required this.pdfPageImage,
    required this.pageNumber,
    required this.width,
    required this.height,
  });

  @override
  PdfObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
    ui.Image? pdfPageImage,
    int? pageNumber,
    double? width,
    double? height,
  }) {
    return PdfObject(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isSelected: isSelected ?? this.isSelected,
      pdfPageImage: pdfPageImage ?? this.pdfPageImage,
      pageNumber: pageNumber ?? this.pageNumber,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Rect getBounds() {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      width * scale,
      height * scale,
    );
  }

  @override
  bool containsPoint(Offset point) {
    return getBounds().contains(point);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'pdf',
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'pageNumber': pageNumber,
      'width': width,
      'height': height,
      'pdfPath': '', // Should be set when loading
    };
  }

  static PdfObject fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('PdfObject.fromJson requires PDF rendering');
  }
}

/// Shape object (rectangle, circle, line)
class ShapeObject extends CanvasObject {
  final ShapeType type;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double width;
  final double height;
  final Offset? endPoint; // For lines

  const ShapeObject({
    required super.id,
    required super.position,
    super.scale = 1.0,
    super.rotation = 0.0,
    required super.zIndex,
    super.isSelected = false,
    required this.type,
    this.fillColor = Colors.transparent,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.width = 100.0,
    this.height = 100.0,
    this.endPoint,
  });

  @override
  ShapeObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
    ShapeType? type,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? width,
    double? height,
    Offset? endPoint,
  }) {
    return ShapeObject(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isSelected: isSelected ?? this.isSelected,
      type: type ?? this.type,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      width: width ?? this.width,
      height: height ?? this.height,
      endPoint: endPoint ?? this.endPoint,
    );
  }

  @override
  Rect getBounds() {
    if (type == ShapeType.line && endPoint != null) {
      final start = position;
      final end = endPoint!;
      return Rect.fromPoints(
        Offset(math.min(start.dx, end.dx), math.min(start.dy, end.dy)),
        Offset(math.max(start.dx, end.dx), math.max(start.dy, end.dy)),
      );
    }
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      width * scale,
      height * scale,
    );
  }

  @override
  bool containsPoint(Offset point) {
    final bounds = getBounds();
    if (type == ShapeType.line) {
      // Check if point is near the line
      if (endPoint == null) return false;
      final start = position;
      final end = endPoint!;
      final distance = _pointToLineDistance(point, start, end);
      return distance < strokeWidth * scale + 10;
    }
    return bounds.contains(point);
  }

  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final A = point.dx - lineStart.dx;
    final B = point.dy - lineStart.dy;
    final C = lineEnd.dx - lineStart.dx;
    final D = lineEnd.dy - lineStart.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    if (lenSq == 0) {
      return math.sqrt(A * A + B * B);
    }

    final param = dot / lenSq;
    final xx = lineStart.dx + param * C;
    final yy = lineStart.dy + param * D;

    final dx = point.dx - xx;
    final dy = point.dy - yy;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'shape',
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'shapeType': type.name,
      'fillColor': fillColor.toARGB32(),
      'strokeColor': strokeColor.toARGB32(),
      'strokeWidth': strokeWidth,
      'width': width,
      'height': height,
      'endPoint': endPoint != null
          ? {'x': endPoint!.dx, 'y': endPoint!.dy}
          : null,
    };
  }

  static ShapeObject fromJson(Map<String, dynamic> json) {
    return ShapeObject(
      id: json['id'] as String,
      position: Offset(
        (json['position'] as Map)['x'] as double,
        (json['position'] as Map)['y'] as double,
      ),
      scale: json['scale'] as double? ?? 1.0,
      rotation: json['rotation'] as double? ?? 0.0,
      zIndex: json['zIndex'] as int,
      type: ShapeType.values.firstWhere(
        (e) => e.name == json['shapeType'],
        orElse: () => ShapeType.rectangle,
      ),
      fillColor: Color(json['fillColor'] as int),
      strokeColor: Color(json['strokeColor'] as int),
      strokeWidth: json['strokeWidth'] as double? ?? 2.0,
      width: json['width'] as double? ?? 100.0,
      height: json['height'] as double? ?? 100.0,
      endPoint: json['endPoint'] != null
          ? Offset(
              (json['endPoint'] as Map)['x'] as double,
              (json['endPoint'] as Map)['y'] as double,
            )
          : null,
    );
  }
}

enum ShapeType { rectangle, circle, line }

/// Freehand drawing object
class DrawingObject extends CanvasObject {
  final List<DrawingStroke> strokes;
  final double width;
  final double height;

  const DrawingObject({
    required super.id,
    required super.position,
    super.scale = 1.0,
    super.rotation = 0.0,
    required super.zIndex,
    super.isSelected = false,
    required this.strokes,
    this.width = 0,
    this.height = 0,
  });

  @override
  DrawingObject copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    bool? isSelected,
    List<DrawingStroke>? strokes,
    double? width,
    double? height,
  }) {
    return DrawingObject(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isSelected: isSelected ?? this.isSelected,
      strokes: strokes ?? this.strokes,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Rect getBounds() {
    if (strokes.isEmpty) {
      return Rect.fromLTWH(position.dx, position.dy, width, height);
    }
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in strokes) {
      for (final point in stroke.points) {
        final adjustedPoint = position + point;
        minX = math.min(minX, adjustedPoint.dx);
        minY = math.min(minY, adjustedPoint.dy);
        maxX = math.max(maxX, adjustedPoint.dx);
        maxY = math.max(maxY, adjustedPoint.dy);
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool containsPoint(Offset point) {
    // Check if point is near any stroke
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = position + stroke.points[i];
        final p2 = position + stroke.points[i + 1];
        final distance = _pointToLineDistance(point, p1, p2);
        if (distance < stroke.width * scale + 10) {
          return true;
        }
      }
    }
    return false;
  }

  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final A = point.dx - lineStart.dx;
    final B = point.dy - lineStart.dy;
    final C = lineEnd.dx - lineStart.dx;
    final D = lineEnd.dy - lineStart.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    if (lenSq == 0) {
      return math.sqrt(A * A + B * B);
    }

    final param = dot / lenSq;
    final xx = lineStart.dx + param * C;
    final yy = lineStart.dy + param * D;

    final dx = point.dx - xx;
    final dy = point.dy - yy;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'drawing',
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'strokes': strokes.map((s) => s.toJson()).toList(),
      'width': width,
      'height': height,
    };
  }

  static DrawingObject fromJson(Map<String, dynamic> json) {
    return DrawingObject(
      id: json['id'] as String,
      position: Offset(
        (json['position'] as Map)['x'] as double,
        (json['position'] as Map)['y'] as double,
      ),
      scale: json['scale'] as double? ?? 1.0,
      rotation: json['rotation'] as double? ?? 0.0,
      zIndex: json['zIndex'] as int,
      strokes: (json['strokes'] as List)
          .map((s) => DrawingStroke.fromJson(s))
          .toList(),
      width: json['width'] as double? ?? 0,
      height: json['height'] as double? ?? 0,
    );
  }
}

/// Represents a single drawing stroke
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final DrawingTool tool;

  const DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.toARGB32(),
      'width': width,
      'tool': tool.name,
    };
  }

  static DrawingStroke fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List)
          .map(
            (p) => Offset((p as Map)['x'] as double, (p as Map)['y'] as double),
          )
          .toList(),
      color: Color(json['color'] as int),
      width: json['width'] as double,
      tool: DrawingTool.values.firstWhere(
        (e) => e.name == json['tool'],
        orElse: () => DrawingTool.pencil,
      ),
    );
  }
}

enum DrawingTool { pencil, marker, eraser }
