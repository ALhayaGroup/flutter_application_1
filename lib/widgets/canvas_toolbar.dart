import 'package:flutter/material.dart';
import '../models/canvas_object.dart';
import '../services/canvas_controller.dart';

/// Toolbar for adding objects and selecting drawing tools
class CanvasToolbar extends StatelessWidget {
  final CanvasController controller;

  const CanvasToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Drawing tools
                _ToolButton(
                  icon: Icons.edit,
                  label: 'Pencil',
                  isSelected:
                      controller.currentDrawingTool == DrawingTool.pencil,
                  onTap: () => controller.setDrawingTool(DrawingTool.pencil),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.brush,
                  label: 'Marker',
                  isSelected:
                      controller.currentDrawingTool == DrawingTool.marker,
                  onTap: () => controller.setDrawingTool(DrawingTool.marker),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.cleaning_services,
                  label: 'Eraser',
                  isSelected:
                      controller.currentDrawingTool == DrawingTool.eraser,
                  onTap: () => controller.setDrawingTool(DrawingTool.eraser),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(),
                const SizedBox(width: 8),
                // Object tools
                _ToolButton(
                  icon: Icons.text_fields,
                  label: 'Text',
                  onTap: () => _addTextObject(context),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.image,
                  label: 'Image',
                  onTap: () => _addImageObject(context),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  onTap: () => _addPdfObject(context),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.crop_square,
                  label: 'Rectangle',
                  onTap: () => _addShapeObject(ShapeType.rectangle),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.circle,
                  label: 'Circle',
                  onTap: () => _addShapeObject(ShapeType.circle),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.remove,
                  label: 'Line',
                  onTap: () => _addShapeObject(ShapeType.line),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTextObject(BuildContext context) {
    final textObj = TextObject(
      id: _generateId(),
      position: const Offset(100, 100),
      zIndex: controller.objects.length,
      text: 'Double tap to edit',
    );
    controller.addObject(textObj);
    controller.selectObject(textObj.id);
  }

  void _addImageObject(BuildContext context) {
    // In a real implementation, this would open file picker
    // For now, we'll show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: const Text(
          'Image picker not implemented. Use a file picker package in production.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addPdfObject(BuildContext context) {
    // In a real implementation, this would open file picker and render PDF
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add PDF'),
        content: const Text(
          'PDF picker not implemented. Use a PDF rendering package in production.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addShapeObject(ShapeType type) {
    final shapeObj = ShapeObject(
      id: _generateId(),
      position: const Offset(200, 200),
      zIndex: controller.objects.length,
      type: type,
      width: type == ShapeType.line ? 0 : 100,
      height: type == ShapeType.line ? 0 : 100,
      endPoint: type == ShapeType.line ? const Offset(300, 300) : null,
    );
    controller.addObject(shapeObj);
    controller.selectObject(shapeObj.id);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
