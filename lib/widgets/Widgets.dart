import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

TextEditingController dialogTitleController = TextEditingController();
TextEditingController dialogAmountController = TextEditingController();

FilteringTextInputFormatter amountInputFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

Widget yellowButton(
    {@required BuildContext context,
    @required onPressed,
    @required String text,
    bool isLarge}) {
  if (isLarge == null) isLarge = false;
  return SizedBox(
    height: 50,
    width: MediaQuery.of(context).size.width * (isLarge ? 0.7 : 0.3),
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: Theme.of(context).accentColor,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      onPressed: onPressed,
    ),
  );
}

Widget circleAvatar(
    {@required Color color,
    @required Color textColor,
    @required String mainText,
    String secondText}) {
  return CircleAvatar(
    radius: 65,
    backgroundColor: color,
    child: Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              child: Text(
                mainText,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (secondText != null)
            Text(
              secondText,
              style: TextStyle(color: textColor, fontSize: 18),
            ),
        ],
      ),
    ),
  );
}

Widget newItemListTile(
    {@required String text, @required Color color, @required onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: ListTile(
      title: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
      ),
      trailing: Icon(Icons.add_circle, size: 35, color: color),
    ),
  );
}

Future<dynamic> alertDialogFields(
    {@required BuildContext context,
    @required onPressedOk,
    String title,
    String hintText}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.height * 0.7,
              padding: EdgeInsets.only(top: 15, left: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, top: 10),
                    child: TextField(
                      controller: dialogTitleController,
                      decoration: InputDecoration(
                        hintText: hintText ?? "",
                      ),
                      maxLength: 30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: TextField(
                      controller: dialogAmountController,
                      decoration: InputDecoration(
                        hintText: "Amount",
                        suffixIcon: Icon(Icons.euro_symbol, size: 15),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        amountInputFormatter,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(child: Text("Save"), onPressed: onPressedOk),
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}

Future<dynamic> simpleAlertDialog(
    {@required BuildContext context,
    @required onPressedOk,
    @required String title,
    @required String contentText}) {
  return showDialog(
    context: context,
    child: AlertDialog(
      title: Text(
        title ?? "",
        style: TextStyle(fontSize: 18),
      ),
      content: Text(contentText),
      actions: [
        FlatButton(child: Text("Ok"), onPressed: onPressedOk),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Future<dynamic> pushReplacement(
    {@required BuildContext context, @required nextScreen}) {
  return Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => nextScreen,
    ),
  );
}

Future<dynamic> push({@required BuildContext context, @required nextScreen}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => nextScreen,
    ),
  );
}

void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());

String formattedDate(String date) =>
    DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

Widget snackBar(
    {@required BuildContext context,
    @required String infoMessage,
    @required Color backgroundColor}) {
  return Flushbar(
    message: infoMessage,
    backgroundColor: backgroundColor,
    duration: Duration(seconds: 3),
  )..show(context);
}
