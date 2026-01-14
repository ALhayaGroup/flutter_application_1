import 'package:flutter/material.dart';
import 'package:flutter_application_1/my_drawing.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyDrawingPage()),
            );
          },
          child: Center(child: Text('Hello World!')),
        ),
      ),
    );
  }
}
