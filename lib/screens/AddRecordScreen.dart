import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddRecordScreen extends StatefulWidget {
  @override
  AddRecordScreenState createState() => AddRecordScreenState();
}

class AddRecordScreenState extends State<AddRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Add new record screen."),
      ),
    );
  }
}
