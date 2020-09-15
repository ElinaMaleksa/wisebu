import 'package:flutter/material.dart';
import 'package:wisebu/screens/OpenScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiseBu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF0072B1),
        accentColor: Color(0xFFF3C623),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpenScreen(),
    );
  }
}
