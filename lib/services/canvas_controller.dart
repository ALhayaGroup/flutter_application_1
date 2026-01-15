import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/canvas_object.dart';

/// Controller for managing canvas state and operations
class CanvasController extends ChangeNotifier {
  final List<CanvasObject> _objects = [];
  String? _selectedObjectId;
  DrawingTool _currentDrawingTool = DrawingTool.pencil;
  Color _currentDrawingColor = Colors.black;
  double _currentDrawingWidth = 2.0;
  int _nextZIndex = 0;
  DrawingObject? _currentDrawing;
  List<DrawingStroke> _currentStrokes = [];
  DrawingStroke? _currentStroke;

  List<CanvasObject> get objects => List.unmodifiable(_objects);
  String? get selectedObjectId => _selectedObjectId;
  CanvasObject? get selectedObject => _selectedObjectId != null
      ? _objects.firstWhere(
          (obj) => obj.id == _selectedObjectId,
          orElse: () => throw StateError('Selected object not found'),
        )
      : null;
  DrawingTool get currentDrawingTool => _currentDrawingTool;
  Color get currentDrawingColor => _currentDrawingColor;
  double get currentDrawingWidth => _currentDrawingWidth;

  /// Add an object to the canvas
  void addObject(CanvasObject object) {
    _objects.add(object);
    _nextZIndex = math.max(_nextZIndex, object.zIndex + 1);
    notifyListeners();
  }

  /// Remove an object from the canvas
  void removeObject(String id) {
    _objects.removeWhere((obj) => obj.id == id);
    if (_selectedObjectId == id) {
      _selectedObjectId = null;
    }
    notifyListeners();
  }

  /// Update an object
  void updateObject(String id, CanvasObject Function(CanvasObject) updater) {
    final index = _objects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _objects[index] = updater(_objects[index]);
      notifyListeners();
    }
  }

  /// Select an object
  void selectObject(String? id) {
    if (_selectedObjectId == id) return;

    // Deselect current object
    if (_selectedObjectId != null) {
      final currentIndex = _objects.indexWhere(
        (obj) => obj.id == _selectedObjectId,
      );
      if (currentIndex != -1) {
        _objects[currentIndex] = _objects[currentIndex].copyWith(
          isSelected: false,
        );
      }
    }

    _selectedObjectId = id;

    // Select new object
    if (id != null) {
      final index = _objects.indexWhere((obj) => obj.id == id);
      if (index != -1) {
        _objects[index] = _objects[index].copyWith(isSelected: true);
      }
    }

    notifyListeners();
  }

  /// Deselect all objects
  void deselectAll() {
    selectObject(null);
  }

  /// Move an object
  void moveObject(String id, Offset delta) {
    updateObject(id, (obj) {
      return obj.copyWith(position: obj.position + delta);
    });
  }

  /// Scale an object
  void scaleObject(String id, double scale) {
    updateObject(id, (obj) {
      return obj.copyWith(scale: (obj.scale * scale).clamp(0.1, 10.0));
    });
  }

  /// Rotate an object
  void rotateObject(String id, double deltaRotation) {
    updateObject(id, (obj) {
      return obj.copyWith(rotation: obj.rotation + deltaRotation);
    });
  }

  /// Bring object to front
  void bringToFront(String id) {
    final index = _objects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      final obj = _objects.removeAt(index);
      _objects.add(obj.copyWith(zIndex: _nextZIndex++));
      notifyListeners();
    }
  }

  /// Send object to back
  void sendToBack(String id) {
    final index = _objects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      final obj = _objects.removeAt(index);
      _objects.insert(0, obj.copyWith(zIndex: -_nextZIndex++));
      notifyListeners();
    }
  }

  /// Duplicate an object
  void duplicateObject(String id) {
    final index = _objects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      final obj = _objects[index];
      final newId = _generateId();
      final newObj = obj.copyWith(
        id: newId,
        position: obj.position + const Offset(20, 20),
        zIndex: _nextZIndex++,
        isSelected: false,
      );
      _objects.add(newObj);
      notifyListeners();
    }
  }

  /// Find object at point (considering z-order)
  CanvasObject? findObjectAt(Offset point) {
    // Search from top to bottom (reverse order)
    for (int i = _objects.length - 1; i >= 0; i--) {
      final obj = _objects[i];
      if (obj.containsPoint(point)) {
        return obj;
      }
    }
    return null;
  }

  /// Set drawing tool
  void setDrawingTool(DrawingTool tool) {
    _finishCurrentDrawing();
    _currentDrawingTool = tool;
    notifyListeners();
  }

  /// Set drawing color
  void setDrawingColor(Color color) {
    _currentDrawingColor = color;
    notifyListeners();
  }

  /// Set drawing width
  void setDrawingWidth(double width) {
    _currentDrawingWidth = width;
    notifyListeners();
  }

  /// Start a new drawing stroke
  void startDrawing(Offset point) {
    if (_currentDrawingTool == DrawingTool.eraser) {
      // Eraser removes parts of existing drawings
      _eraseAtPoint(point);
      return;
    }

    _currentStroke = DrawingStroke(
      points: [point],
      color: _currentDrawingColor,
      width: _currentDrawingWidth,
      tool: _currentDrawingTool,
    );

    _currentDrawing ??= DrawingObject(
      id: _generateId(),
      position: Offset.zero,
      zIndex: _nextZIndex++,
      strokes: [],
    );
  }

  /// Continue drawing stroke
  void continueDrawing(Offset point) {
    if (_currentStroke == null) return;

    _currentStroke = DrawingStroke(
      points: [..._currentStroke!.points, point],
      color: _currentStroke!.color,
      width: _currentStroke!.width,
      tool: _currentStroke!.tool,
    );
    notifyListeners();
  }

  /// Finish current drawing stroke
  void finishDrawingStroke() {
    if (_currentStroke == null || _currentDrawing == null) return;

    _currentStrokes = [..._currentStrokes, _currentStroke!];
    _currentDrawing = _currentDrawing!.copyWith(strokes: _currentStrokes);
    _currentStroke = null;
    notifyListeners();
  }

  /// Finish entire drawing
  void _finishCurrentDrawing() {
    if (_currentDrawing != null && _currentStrokes.isNotEmpty) {
      _objects.add(_currentDrawing!);
      _currentDrawing = null;
      _currentStrokes = [];
      _currentStroke = null;
      notifyListeners();
    }
  }

  /// Erase at point
  void _eraseAtPoint(Offset point) {
    // Find drawing objects and remove strokes near the point
    for (int i = _objects.length - 1; i >= 0; i--) {
      final obj = _objects[i];
      if (obj is DrawingObject) {
        final drawing = obj;
        final updatedStrokes = <DrawingStroke>[];
        bool modified = false;

        for (final stroke in drawing.strokes) {
          final filteredPoints = <Offset>[];
          for (final strokePoint in stroke.points) {
            final canvasPoint = drawing.position + strokePoint;
            final distance = (canvasPoint - point).distance;
            if (distance > _currentDrawingWidth * 2) {
              filteredPoints.add(strokePoint);
            } else {
              modified = true;
            }
          }
          if (filteredPoints.length >= 2) {
            updatedStrokes.add(
              DrawingStroke(
                points: filteredPoints,
                color: stroke.color,
                width: stroke.width,
                tool: stroke.tool,
              ),
            );
          } else {
            modified = true;
          }
        }

        if (modified) {
          if (updatedStrokes.isEmpty) {
            _objects.removeAt(i);
          } else {
            _objects[i] = drawing.copyWith(strokes: updatedStrokes);
          }
          notifyListeners();
          break;
        }
      }
    }
  }

  /// Get current drawing for rendering
  DrawingObject? get currentDrawing => _currentDrawing?.copyWith(
    strokes: [..._currentStrokes, if (_currentStroke != null) _currentStroke!],
  );

  /// Save canvas to JSON
  String saveToJson() {
    final json = {'objects': _objects.map((obj) => obj.toJson()).toList()};
    return jsonEncode(json);
  }

  /// Load canvas from JSON
  Future<void> loadFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final objectsJson = json['objects'] as List;
      _objects.clear();
      _selectedObjectId = null;
      _nextZIndex = 0;

      for (final objJson in objectsJson) {
        try {
          final obj = CanvasObject.fromJson(objJson as Map<String, dynamic>);
          _objects.add(obj);
          _nextZIndex = math.max(_nextZIndex, obj.zIndex + 1);
        } catch (e) {
          // Skip objects that can't be loaded (e.g., images, PDFs)
          debugPrint('Failed to load object: $e');
        }
      }
      _nextZIndex++;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load canvas: $e');
    }
  }

  /// Clear all objects
  void clear() {
    _objects.clear();
    _selectedObjectId = null;
    _nextZIndex = 0;
    _finishCurrentDrawing();
    notifyListeners();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        math.Random().nextInt(1000).toString();
  }

  @override
  void dispose() {
    _finishCurrentDrawing();
    super.dispose();
  }
}
