import 'package:flutter/material.dart';
import 'package:wisebu/screens/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WiseBu',
      theme: ThemeData(
        fontFamily: "Spartan",
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF0072B1),
        accentColor: Color(0xFFF3C623),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // color for date picker same as primaryColor
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0072B1),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
