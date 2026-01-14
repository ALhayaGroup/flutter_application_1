import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:pdfx/pdfx.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TransformationController _transformationController =
      TransformationController();

  final Map<int, DrawingController> _pageDrawings = {};

  late PdfController _pdfController;

  int _currentPage = 1;
  int _totalPages = 0;

  double _colorOpacity = 1;

  /// Get drawing controller for current PDF page
  DrawingController get _drawingController {
    return _pageDrawings.putIfAbsent(_currentPage, () => DrawingController());
  }

  @override
  void initState() {
    super.initState();

    _pdfController = PdfController(
      document: PdfDocument.openAsset('assets/demo-link.pdf'),
    );

    _pdfController.loadingState.addListener(() {
      if (_pdfController.loadingState.value == PdfLoadingState.success) {
        setState(() {
          _totalPages = _pdfController.pagesCount ?? 0;
        });
      }
    });

    _pdfController.pageListenable.addListener(() {
      final page = _pdfController.pageListenable.value;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _transformationController.value = Matrix4.identity();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final p in _pageDrawings.values) {
      p.dispose();
    }
    _pdfController.dispose();
    super.dispose();
  }

  void _showJson() {
    showDialog(
      context: context,
      builder: (_) => Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent(
                '  ',
              ).convert(_drawingController.getJsonList()),
            ),
          ),
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text('PDF Draw (${_currentPage}/$_totalPages)'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: PopupMenuButton<ui.Color>(
          icon: const Icon(Icons.color_lens),
          onSelected: (ui.Color value) {
            _drawingController.setStyle(
              color: value.withValues(alpha: _colorOpacity),
            );
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              child: StatefulBuilder(
                builder: (_, setState) {
                  return Slider(
                    value: _colorOpacity,
                    onChanged: (v) {
                      setState(() => _colorOpacity = v);
                      _drawingController.setStyle(
                        color: _drawingController.drawConfig.value.color
                            .withValues(alpha: _colorOpacity),
                      );
                    },
                  );
                },
              ),
            ),
            ...Colors.accents.map(
              (c) => PopupMenuItem(
                value: c,
                child: Container(height: 30, color: c),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.javascript), onPressed: _showJson),
          IconButton(icon: const Icon(Icons.restore), onPressed: _resetZoom),
        ],
      ),
      body: Stack(
        children: [
          /// PDF VIEW
          PdfView(controller: _pdfController, scrollDirection: Axis.vertical),

          /// DRAWING LAYER
          LayoutBuilder(
            builder: (context, constraints) {
              return DrawingBoard(
                controller: _drawingController,
                transformationController: _transformationController,
                background: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.transparent,
                ),
              );
            },
          ),

          /// PAGE CONTROLS
          Positioned(
            right: 10,
            top: 100,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onPressed: () {
                    _pdfController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () {
                    _pdfController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),
              ],
            ),
          ),

          /// TOOLBARS
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: DrawingBar(
              controller: _drawingController,
              tools: [
                DefaultActionItem.undo(),
                DefaultActionItem.redo(),
                DefaultActionItem.clear(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DrawingBar(
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
          ),
        ],
      ),
    );
  }
}
