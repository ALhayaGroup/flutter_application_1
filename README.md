# Freeform Canvas - Flutter Application

A Flutter application inspired by Apple Freeform, featuring an infinite, scrollable, and zoomable canvas for creating and organizing content. Built using only Flutter SDK and `dart:ui` - no third-party drawing or canvas packages.

## Features

### ✨ Core Functionality

1. **Infinite Canvas**
   - Scrollable and zoomable canvas with no fixed boundaries
   - Pinch-to-zoom support
   - Pan gestures for navigation
   - Double-tap to reset zoom

2. **Canvas Objects**
   - **Text Boxes**: Editable text objects with customizable font size, color, and weight
   - **Images**: Support for adding images (file picker integration needed for production)
   - **PDF Pages**: Render PDF pages as images (PDF rendering needed for production)
   - **Shapes**: Rectangle, circle, and line shapes with customizable colors and stroke width
   - **Freehand Drawing**: Pencil, marker, and eraser tools

3. **Object Manipulation**
   - **Drag**: Move objects by dragging
   - **Select**: Tap to select objects (shows selection border with handles)
   - **Scale**: Pinch to scale selected objects (future enhancement)
   - **Rotate**: Rotate objects (future enhancement)
   - **Layer Management**: Bring to front / Send to back via context menu

4. **Drawing Tools**
   - **Pencil**: Thin stroke for precise drawing
   - **Marker**: Thicker, semi-transparent stroke
   - **Eraser**: Remove parts of drawings
   - Adjustable stroke width
   - Color picker for drawing colors

5. **Gestures**
   - Single tap: Select/deselect objects
   - Drag: Move selected objects or draw (depending on tool)
   - Pinch: Zoom canvas
   - Two-finger pan: Pan canvas
   - Long press: Open context menu (delete, duplicate, layer order)
   - Double tap: Edit text objects or reset zoom

6. **Persistence**
   - Save canvas state to JSON (currently clipboard)
   - Load canvas state from JSON
   - Restore objects with correct transformations

## Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── home.dart                 # Main screen with canvas and toolbar
├── models/
│   └── canvas_object.dart    # Data models for all canvas objects
├── services/
│   └── canvas_controller.dart # Canvas state management
├── widgets/
│   ├── infinite_canvas.dart  # Infinite canvas widget with gesture handling
│   ├── canvas_toolbar.dart   # Toolbar for adding objects and tools
│   ├── drawing_painter.dart  # Custom painter for freehand drawings
│   ├── object_renderer.dart  # Object rendering utilities
│   ├── color_picker_dialog.dart # Color selection dialog
│   └── text_editor_dialog.dart  # Text editing dialog
└── utils/
    └── canvas_math.dart      # Canvas transformation utilities
```

### Key Components

#### CanvasObject (Abstract Base Class)
Base class for all objects on the canvas with common properties:
- Position (Offset)
- Scale
- Rotation (radians)
- Z-index (layer order)
- Selection state

#### CanvasController
Manages canvas state and operations:
- Object CRUD operations
- Selection management
- Drawing state
- Layer management (bring to front, send to back)
- Persistence (save/load JSON)

#### InfiniteCanvas
Main canvas widget using `InteractiveViewer`:
- Handles all gestures (tap, drag, pinch, long press)
- Converts screen coordinates to canvas coordinates
- Renders objects using `CustomPainter`
- Manages drawing interactions

#### CanvasPainter
Custom painter that renders:
- All canvas objects (text, images, PDFs, shapes, drawings)
- Selection borders with resize handles
- Current drawing strokes

## Canvas Math & Transformations

The app uses matrix transformations to handle coordinate conversions:

- **Screen to Canvas**: Invert the transformation matrix to convert touch coordinates
- **Object Transformations**: Apply position, scale, and rotation in correct order
- **Hit Testing**: Account for rotation when checking if a point is within an object

Key transformation order:
1. Translate to origin
2. Rotate
3. Scale
4. Translate to position

## Usage

### Adding Objects

1. **Text**: Tap "Text" in toolbar, then double-tap the text object to edit
2. **Shapes**: Tap shape icon (rectangle, circle, line) in toolbar
3. **Drawing**: Select pencil/marker tool and draw on canvas
4. **Eraser**: Select eraser tool and drag over drawings to erase

### Manipulating Objects

1. **Select**: Tap an object
2. **Move**: Drag a selected object
3. **Edit**: Double-tap text objects to edit
4. **Layer**: Long-press for context menu → Bring to Front / Send to Back
5. **Delete**: Long-press → Delete
6. **Duplicate**: Long-press → Duplicate

### Canvas Navigation

1. **Pan**: Drag with one finger (when not drawing)
2. **Zoom**: Pinch to zoom in/out
3. **Reset Zoom**: Double-tap empty canvas area

### Saving & Loading

1. **Save**: Tap save icon (copies JSON to clipboard)
2. **Load**: Tap load icon (loads JSON from clipboard)

## Example Data

The app loads example data on startup:
- Welcome text object
- Blue rectangle shape
- Green circle shape

## Performance Optimizations

1. **RepaintBoundary**: Used around canvas to minimize repaints
2. **Efficient Rendering**: Objects sorted by z-index for correct rendering order
3. **Custom Painter**: Direct canvas drawing for optimal performance
4. **State Management**: ChangeNotifier pattern for efficient updates

## Future Enhancements

- Image file picker integration
- PDF rendering and file picker
- Object scaling via pinch gesture
- Object rotation via rotation gesture
- Resize handles for interactive scaling
- Undo/redo functionality
- File system persistence (beyond clipboard)
- Export canvas as image/PDF
- Multi-select objects
- Group/ungroup objects
- Alignment guides and snapping

## Dependencies

- Flutter SDK only
- No third-party packages (as per requirements)

## Building

```bash
flutter pub get
flutter run
```

## Platform Support

- ✅ iOS
- ✅ Android

## Notes

- Image and PDF objects require file picker and rendering implementations for production use
- Current persistence uses clipboard; file system persistence can be added
- Drawing strokes are smoothed using quadratic bezier curves
- Canvas uses a large fixed size (10000x10000) for infinite feel; can be made truly infinite with dynamic sizing

## License

This project is provided as-is for educational and demonstration purposes.
