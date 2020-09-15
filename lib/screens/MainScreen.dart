import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BUDGET"),
        // disable going back from appBar
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text("This is the main screen."),
      ),
    );
  }
}
