import 'package:flutter/material.dart';

/// Simple color picker dialog
class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 300,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () {
                onColorChanged(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentColor == color ? Colors.blue : Colors.grey,
                    width: currentColor == color ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
