import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

TextEditingController dialogTitleController = TextEditingController();
TextEditingController dialogAmountController = TextEditingController();

FilteringTextInputFormatter amountInputFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

DateTime lastDate = DateTime.now().add(Duration(days: 365));
DateTime firstDate = DateTime.now().subtract(Duration(days: 365));

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
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: Theme.of(context).accentColor,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: isLarge ? FontWeight.bold : null,
          ),
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
              fit: BoxFit.scaleDown,
              child: Text(
                mainText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          if (secondText != null)
            Text(
              secondText,
              style: TextStyle(color: textColor, fontSize: 16),
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

Future<dynamic> alertDialogWithFields(
    {@required BuildContext context,
    @required onPressedOk,
    String title,
    String hintText,
    bool enabled}) {
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
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      controller: dialogTitleController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9 .,?!]")),
                      ],
                      decoration: InputDecoration(
                        hintText: hintText ?? "",
                      ),
                      maxLength: 30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: TextField(
                      enabled: enabled ?? true,
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
                      style: TextStyle(
                        color: enabled ?? true ? Colors.black : Colors.grey,
                      ),
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
    Color backgroundColor}) {
  return Flushbar(
    message: infoMessage,
    backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
    duration: Duration(seconds: 3),
  )..show(context);
}

String amountTextShown({@required double amount}) {
  // round a double with toStringAsFixed(2)
  String value = amount.toStringAsFixed(2);
  String lastChars = value.substring(value.length - 3, value.length);
  if (lastChars == ".00")
    return value.substring(0, value.length - 3);
  else
    return value;
}

Widget inkwellIcon(
        {@required String tooltip,
        @required IconData iconData,
        @required onTap,
        Color color}) =>
// if color == null it is appBar icon
    Tooltip(
        message: tooltip,
        child: InkWell(
            customBorder: CircleBorder(),
            child: Padding(
                padding: EdgeInsets.all(color == null ? 15 : 0),
                child: Icon(
                  iconData,
                  color: color ?? Colors.white,
                  size: color == null ? 25 : 35,
                )),
            onTap: onTap));
