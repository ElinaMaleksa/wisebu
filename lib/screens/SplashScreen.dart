import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/screens/OpenScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(milliseconds: 1000), () {
      checkFirstSeen();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'WiseBu',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstOpen = (prefs.getBool('firstOpen') ?? true);

    // TODO: uncomment this code
    /* if (firstOpen) {
      // insert categories in db on app start
      dbInsertCategories().then(
          (_) => pushReplacement(context: context, nextScreen: OpenScreen()));
      await prefs.setBool('firstOpen', false);
    } else
      pushReplacement(context: context, nextScreen: MainScreen());*/

    push(context: context, nextScreen: OpenScreen());
  }
}
