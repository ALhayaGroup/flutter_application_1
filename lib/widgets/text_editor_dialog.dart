import 'package:flutter/material.dart';
import 'color_picker_dialog.dart';

/// Dialog for editing text objects
class TextEditorDialog extends StatefulWidget {
  final String initialText;
  final double initialFontSize;
  final Color initialColor;
  final FontWeight initialFontWeight;

  const TextEditorDialog({
    super.key,
    required this.initialText,
    this.initialFontSize = 24.0,
    this.initialColor = Colors.black,
    this.initialFontWeight = FontWeight.normal,
  });

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController _textController;
  late double _fontSize;
  late Color _color;
  late FontWeight _fontWeight;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _fontSize = widget.initialFontSize;
    _color = widget.initialColor;
    _fontWeight = widget.initialFontWeight;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Text'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Font Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 72,
                    divisions: 30,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                    },
                  ),
                ),
                Text(_fontSize.round().toString()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Color: '),
                InkWell(
                  onTap: () async {
                    final newColor = await showDialog<Color>(
                      context: context,
                      builder: (context) => ColorPickerDialog(
                        currentColor: _color,
                        onColorChanged: (color) =>
                            Navigator.pop(context, color),
                      ),
                    );
                    if (newColor != null) {
                      setState(() => _color = newColor);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _color,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'text': _textController.text,
              'fontSize': _fontSize,
              'color': _color,
              'fontWeight': _fontWeight,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
