import 'package:flutter/material.dart';
import '../models/canvas_object.dart';

/// Widget for rendering individual canvas objects
/// This is kept for potential future use if we need widget-based rendering
class ObjectRenderer extends StatelessWidget {
  final CanvasObject object;

  const ObjectRenderer({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    // Objects are rendered via CustomPainter in InfiniteCanvas
    // This widget is kept for extensibility
    return const SizedBox.shrink();
  }
}
