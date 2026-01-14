import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class MyDrawingPage extends StatefulWidget {
  const MyDrawingPage({super.key});

  @override
  State<MyDrawingPage> createState() => _MyDrawingPageState();
}

class _MyDrawingPageState extends State<MyDrawingPage> {
  final DrawingController _drawingController = DrawingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Drawing Board
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(color: Colors.white),
            ),
          ),

          // Action Bar (slider, undo, redo, rotate, clear)
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultActionItem.slider(),
              DefaultActionItem.undo(),
              DefaultActionItem.redo(),
              DefaultActionItem.turn(),
              DefaultActionItem.clear(),
            ],
          ),

          // Tool Bar (pen, brush, shapes, eraser)
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultToolItem.pen(),
              DefaultToolItem.brush(),
              DefaultToolItem.rectangle(),
              DefaultToolItem.circle(),
              DefaultToolItem.straightLine(),
              DefaultToolItem.eraser(),
            ],
          ),
        ],
      ),
    );
  }
}
