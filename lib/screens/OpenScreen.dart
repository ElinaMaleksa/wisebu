import 'package:clippy_flutter/arc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/screens/StartIncomesScreen.dart';

class OpenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Arc(
            height: 50,
            clipShadows: [
              ClipShadow(color: Colors.black54, elevation: 15),
            ],
            child: Container(
              color: Colors.blueAccent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Center(child: Text('PICTURE HERE')),
            ),
          ),
          Expanded(
              child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Text(
                    'Classify your expenses to spend wisely.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ))),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width * 0.7,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.08),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Colors.blueAccent,
              child: Text(
                'Let\'s start!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => StartIncomesScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
