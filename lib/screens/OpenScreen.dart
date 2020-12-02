import 'package:clippy_flutter/arc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';
import 'package:wisebu/data/blocs/CategoriesBloc.dart';
import 'package:wisebu/screens/SetupScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class OpenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // to prevent exception from keyboard
        resizeToAvoidBottomPadding: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Arc(
              height: 50,
              clipShadows: [
                ClipShadow(color: Colors.black54, elevation: 15),
              ],
              child: Container(
                color: Theme.of(context).primaryColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                child: Image.asset(
                  "lib/images/illustration.png",
                  scale: 4,
                ),
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
                      style: TextStyle(fontSize: 21),
                    ))),
            Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.08),
              child: yellowButton(
                  context: context,
                  isLarge: true,
                  onPressed: () {
                    pushReplacement(
                      context: context,
                      nextScreen: SetupScreen(
                        type: incomeType,
                        buttonText: "Next",
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                  text: "Let\'s start!"),
            ),
          ],
        ),
      ),
    );
  }
}
