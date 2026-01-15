import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/canvas_controller.dart';
import 'widgets/infinite_canvas.dart';
import 'widgets/canvas_toolbar.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/text_editor_dialog.dart';
import 'models/canvas_object.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CanvasController _canvasController;

  @override
  void initState() {
    super.initState();
    _canvasController = CanvasController();
    _loadExampleData();
  }

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }

  /// Load example data to demonstrate the canvas
  void _loadExampleData() {
    // Add some example objects
    final textObj = TextObject(
      id: 'example_text_1',
      position: const Offset(150, 150),
      zIndex: 0,
      text: 'Welcome to Freeform Canvas!\nDouble tap objects to edit.',
      fontSize: 28,
      color: Colors.blue,
      width: 300,
      height: 100,
    );

    final rectShape = ShapeObject(
      id: 'example_shape_1',
      position: const Offset(500, 200),
      zIndex: 1,
      type: ShapeType.rectangle,
      width: 150,
      height: 100,
      fillColor: Colors.blue.withValues(alpha: 0.3),
      strokeColor: Colors.blue,
      strokeWidth: 3,
    );

    final circleShape = ShapeObject(
      id: 'example_shape_2',
      position: const Offset(700, 200),
      zIndex: 2,
      type: ShapeType.circle,
      width: 100,
      height: 100,
      fillColor: Colors.green.withValues(alpha: 0.3),
      strokeColor: Colors.green,
      strokeWidth: 3,
    );

    _canvasController.addObject(textObj);
    _canvasController.addObject(rectShape);
    _canvasController.addObject(circleShape);
  }

  void _saveCanvas() async {
    final json = _canvasController.saveToJson();
    // In a real app, save to file system or shared preferences
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvas saved to clipboard (JSON)')),
      );
    }
  }

  void _loadCanvas() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      try {
        await _canvasController.loadFromJson(clipboardData!.text!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Canvas loaded from clipboard')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load canvas: $e')));
        }
      }
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: _canvasController.currentDrawingColor,
        onColorChanged: (color) {
          _canvasController.setDrawingColor(color);
        },
      ),
    );
  }

  void _handleObjectDoubleTap(CanvasObject object) {
    if (object is TextObject) {
      _editTextObject(object);
    }
  }

  void _editTextObject(TextObject textObj) {
    showDialog(
      context: context,
      builder: (context) => TextEditorDialog(
        initialText: textObj.text,
        initialFontSize: textObj.fontSize,
        initialColor: textObj.color,
        initialFontWeight: textObj.fontWeight,
      ),
    ).then((result) {
      if (result != null) {
        _canvasController.updateObject(textObj.id, (obj) {
          if (obj is TextObject) {
            return obj.copyWith(
              text: result['text'] as String,
              fontSize: result['fontSize'] as double,
              color: result['color'] as Color,
              fontWeight: result['fontWeight'] as FontWeight,
            );
          }
          return obj;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Freeform Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCanvas,
            tooltip: 'Save Canvas',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _loadCanvas,
            tooltip: 'Load Canvas',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
            tooltip: 'Color Picker',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _canvasController.clear();
                  break;
                case 'zoom_reset':
                  // Zoom reset is handled in InfiniteCanvas
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear Canvas')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Infinite Canvas
          InfiniteCanvas(
            controller: _canvasController,
            onObjectDoubleTap: _handleObjectDoubleTap,
          ),

          // Toolbar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CanvasToolbar(controller: _canvasController),
          ),

          // Drawing width control (if drawing tool is selected)
          ListenableBuilder(
            listenable: _canvasController,
            builder: (context, _) {
              if (_canvasController.currentDrawingTool == DrawingTool.eraser) {
                return const SizedBox.shrink();
              }
              return Positioned(
                right: 16,
                top: 100,
                child: Column(
                  children: [
                    const Text('Width'),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: _canvasController.currentDrawingWidth,
                        min: 1,
                        max: 20,
                        onChanged: (value) {
                          _canvasController.setDrawingWidth(value);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
