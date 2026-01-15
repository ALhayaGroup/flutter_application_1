import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/canvas_object.dart';
import '../services/canvas_controller.dart';
import '../widgets/drawing_painter.dart';

/// Infinite scrollable and zoomable canvas widget
class InfiniteCanvas extends StatefulWidget {
  final CanvasController controller;
  final void Function(CanvasObject)? onObjectDoubleTap;

  const InfiniteCanvas({
    super.key,
    required this.controller,
    this.onObjectDoubleTap,
  });

  @override
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  final TransformationController _transformationController =
      TransformationController();
  String? _draggingObjectId;
  Offset? _dragStartOffset;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    widget.controller.removeListener(_onControllerChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    // Handle transformation changes if needed
  }

  void _onControllerChanged() {
    // Trigger repaint when controller state changes
    setState(() {});
  }

  /// Convert screen coordinates to canvas coordinates
  Offset _screenToCanvas(Offset screenPoint) {
    final matrix = _transformationController.value;
    final inverted = Matrix4.inverted(matrix);
    // Transform point using matrix entries manually
    final x =
        inverted.entry(0, 0) * screenPoint.dx +
        inverted.entry(0, 1) * screenPoint.dy +
        inverted.entry(0, 3);
    final y =
        inverted.entry(1, 0) * screenPoint.dx +
        inverted.entry(1, 1) * screenPoint.dy +
        inverted.entry(1, 3);
    return Offset(x, y);
  }

  /// Handle tap on canvas
  void _handleTapDown(TapDownDetails details) {
    final canvasPoint = _screenToCanvas(details.localPosition);
    final object = widget.controller.findObjectAt(canvasPoint);

    if (object != null) {
      widget.controller.selectObject(object.id);
    } else {
      widget.controller.deselectAll();
    }
  }

  /// Handle double tap to reset zoom
  void _handleDoubleTap(_) {
    _transformationController.value = Matrix4.identity();
  }

  /// Handle pan start (for object dragging or canvas panning)
  void _handlePanStart(DragStartDetails details) {
    final canvasPoint = _screenToCanvas(details.localPosition);
    final object = widget.controller.findObjectAt(canvasPoint);

    // Check if we're in drawing mode (pencil, marker, or eraser)
    final isDrawingMode = widget.controller.currentDrawingTool == DrawingTool.pencil ||
        widget.controller.currentDrawingTool == DrawingTool.marker ||
        widget.controller.currentDrawingTool == DrawingTool.eraser;

    if (object != null && object.isSelected && !isDrawingMode) {
      // Start dragging object (only when not in drawing mode)
      _draggingObjectId = object.id;
      _dragStartOffset = canvasPoint - object.position;
    } else if (isDrawingMode) {
      // Start drawing when a drawing tool is selected
      _isDrawing = true;
      widget.controller.startDrawing(canvasPoint);
    }
    // Otherwise, let InteractiveViewer handle panning (when no drawing tool is active)
  }

  /// Handle pan update
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_draggingObjectId != null) {
      // Drag object
      final canvasPoint = _screenToCanvas(details.localPosition);
      final object = widget.controller.selectedObject;
      if (object != null && _dragStartOffset != null) {
        final newPosition = canvasPoint - _dragStartOffset!;
        widget.controller.updateObject(
          _draggingObjectId!,
          (obj) => obj.copyWith(position: newPosition),
        );
      }
    } else if (_isDrawing) {
      // Continue drawing
      final canvasPoint = _screenToCanvas(details.localPosition);
      widget.controller.continueDrawing(canvasPoint);
    } else if (widget.controller.currentDrawingTool == DrawingTool.eraser) {
      // Erase
      final canvasPoint = _screenToCanvas(details.localPosition);
      widget.controller.startDrawing(canvasPoint);
    }
  }

  /// Handle pan end
  void _handlePanEnd(DragEndDetails details) {
    if (_draggingObjectId != null) {
      _draggingObjectId = null;
      _dragStartOffset = null;
    } else if (_isDrawing) {
      _isDrawing = false;
      widget.controller.finishDrawingStroke();
    }
  }

  /// Handle long press (context menu)
  void _handleLongPress(LongPressStartDetails details) {
    final canvasPoint = _screenToCanvas(details.localPosition);
    final object = widget.controller.findObjectAt(canvasPoint);

    if (object != null) {
      _showContextMenu(details.globalPosition, object);
    }
  }

  /// Show context menu for object
  void _showContextMenu(Offset position, CanvasObject object) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'bringToFront',
          child: Text('Bring to Front'),
        ),
        const PopupMenuItem(value: 'sendToBack', child: Text('Send to Back')),
        const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'bringToFront':
            widget.controller.bringToFront(object.id);
            break;
          case 'sendToBack':
            widget.controller.sendToBack(object.id);
            break;
          case 'duplicate':
            widget.controller.duplicateObject(object.id);
            break;
          case 'delete':
            widget.controller.removeObject(object.id);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in drawing mode (pencil, marker, or eraser)
    final isDrawingMode = widget.controller.currentDrawingTool == DrawingTool.pencil ||
        widget.controller.currentDrawingTool == DrawingTool.marker ||
        widget.controller.currentDrawingTool == DrawingTool.eraser;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onDoubleTap: () {
        // Reset zoom on double tap (when no object is tapped)
        _transformationController.value = Matrix4.identity();
      },
      onDoubleTapDown: _handleDoubleTap,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onLongPressStart: _handleLongPress,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 10.0,
        // Disable panning when in drawing mode or when dragging an object
        // This allows single-finger gestures to be used for drawing instead of panning
        panEnabled: !isDrawingMode && _draggingObjectId == null,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: CanvasPainter(
              controller: widget.controller,
              transformation: _transformationController.value,
            ),
            child: const SizedBox(width: 10000, height: 10000),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering canvas objects
class CanvasPainter extends CustomPainter {
  final CanvasController controller;
  final Matrix4 transformation;

  CanvasPainter({required this.controller, required this.transformation});

  @override
  void paint(Canvas canvas, Size size) {
    // Sort objects by z-index for correct rendering order
    final sortedObjects = List<CanvasObject>.from(controller.objects)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Draw all objects
    for (final object in sortedObjects) {
      _drawObject(canvas, object);
    }

    // Draw current drawing if active
    final currentDrawing = controller.currentDrawing;
    if (currentDrawing != null) {
      _drawDrawing(canvas, currentDrawing);
    }
  }

  void _drawObject(Canvas canvas, CanvasObject object) {
    canvas.save();

    // Apply transformations
    canvas.translate(object.position.dx, object.position.dy);
    canvas.scale(object.scale);
    canvas.rotate(object.rotation);

    // Draw based on object type
    if (object is TextObject) {
      _drawText(canvas, object);
    } else if (object is ImageObject) {
      _drawImage(canvas, object);
    } else if (object is PdfObject) {
      _drawPdf(canvas, object);
    } else if (object is ShapeObject) {
      _drawShape(canvas, object);
    } else if (object is DrawingObject) {
      _drawDrawing(canvas, object);
    }

    canvas.restore();

    // Draw selection border if selected
    if (object.isSelected) {
      _drawSelectionBorder(canvas, object);
    }
  }

  void _drawText(Canvas canvas, TextObject textObj) {
    final textSpan = TextSpan(
      text: textObj.text,
      style: TextStyle(
        fontSize: textObj.fontSize,
        color: textObj.color,
        fontWeight: textObj.fontWeight,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: textObj.width);
    textPainter.paint(canvas, Offset.zero);
  }

  void _drawImage(Canvas canvas, ImageObject imageObj) {
    final rect = Rect.fromLTWH(0, 0, imageObj.width, imageObj.height);
    canvas.drawImageRect(
      imageObj.image,
      Rect.fromLTWH(
        0,
        0,
        imageObj.image.width.toDouble(),
        imageObj.image.height.toDouble(),
      ),
      rect,
      Paint(),
    );
  }

  void _drawPdf(Canvas canvas, PdfObject pdfObj) {
    final rect = Rect.fromLTWH(0, 0, pdfObj.width, pdfObj.height);
    canvas.drawImageRect(
      pdfObj.pdfPageImage,
      Rect.fromLTWH(
        0,
        0,
        pdfObj.pdfPageImage.width.toDouble(),
        pdfObj.pdfPageImage.height.toDouble(),
      ),
      rect,
      Paint(),
    );
  }

  void _drawShape(Canvas canvas, ShapeObject shapeObj) {
    final paint = Paint()
      ..color = shapeObj.fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = shapeObj.strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = shapeObj.strokeWidth;

    switch (shapeObj.type) {
      case ShapeType.rectangle:
        final rect = Rect.fromLTWH(0, 0, shapeObj.width, shapeObj.height);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);
        break;
      case ShapeType.circle:
        final center = Offset(shapeObj.width / 2, shapeObj.height / 2);
        final radius = math.min(shapeObj.width, shapeObj.height) / 2;
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(center, radius, strokePaint);
        break;
      case ShapeType.line:
        if (shapeObj.endPoint != null) {
          final start = Offset.zero;
          final end = shapeObj.endPoint! - shapeObj.position;
          canvas.drawLine(start, end, strokePaint);
        }
        break;
    }
  }

  void _drawDrawing(Canvas canvas, DrawingObject drawingObj) {
    final painter = DrawingPainter(drawingObj.strokes);
    painter.paint(canvas, Size.infinite);
  }

  void _drawSelectionBorder(Canvas canvas, CanvasObject object) {
    final bounds = object.getBounds();
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw selection rectangle
    canvas.drawRect(bounds, borderPaint);

    // Draw resize handles (corners and edges)
    final handleSize = 8.0;
    final handles = [
      bounds.topLeft,
      bounds.topCenter,
      bounds.topRight,
      bounds.centerLeft,
      bounds.centerRight,
      bounds.bottomLeft,
      bounds.bottomCenter,
      bounds.bottomRight,
    ];

    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final handle in handles) {
      canvas.drawRect(
        Rect.fromCenter(center: handle, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.transformation != transformation;
  }
}
