import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

TextEditingController dialogTitleController = TextEditingController();
TextEditingController dialogAmountController = TextEditingController();

FilteringTextInputFormatter amountInputFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

FilteringTextInputFormatter textInputFormatter =
    FilteringTextInputFormatter.allow(
        RegExp("[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEFa-zA-Z0-9 \)\(,./!?]"));

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

bool isPortrait(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.portrait;

Widget circleAvatar(
    {@required Color color,
    @required Color textColor,
    @required String mainText,
    String secondText,
    BuildContext context}) {
  return CircleAvatar(
    radius:
        MediaQuery.of(context).size.height * (isPortrait(context) ? 0.1 : 0.2),
    backgroundColor: color,
    child: Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  mainText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textScaleFactor: 0.2,
                ),
              ),
            ),
          ),
          if (secondText != null)
            Text(
              secondText,
              style: TextStyle(
                color: textColor,
              ),
              textScaleFactor: 1,
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
        style: TextStyle(fontSize: 17, color: Colors.grey[500]),
      ),
      trailing: Icon(Icons.add_circle, size: 35, color: color),
    ),
  );
}

Future<dynamic> alertDialog(
    {@required BuildContext context,
    @required onPressedOk,
    String title,
    String hintText,
    bool enabled,
    String contentText,
    @required bool haveTextFields,
    String okButtonName}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Container(
                      padding: EdgeInsets.only(right: 30, left: 15),
                      child: Text(
                        title ?? "",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (haveTextFields)
                    Padding(
                      padding: EdgeInsets.only(right: 15, top: 10, left: 15),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.sentences,
                        controller: dialogTitleController,
                        inputFormatters: [
                          textInputFormatter,
                        ],
                        decoration: InputDecoration(
                          hintText: hintText ?? "",
                        ),
                        maxLength: 30,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  if (haveTextFields)
                    Padding(
                      padding: EdgeInsets.only(right: 15, left: 15),
                      child: TextField(
                        textInputAction: TextInputAction.done,
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
                  // in case of simple alert dialog
                  if (!haveTextFields)
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        contentText ?? "",
                        style: TextStyle(height: 1.5),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Column(
                      children: [
                        Container(
                          height: 0.5,
                          color: Theme.of(context).primaryColor,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                highlightColor: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(18)),
                                onTap: onPressedOk,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  child: Text(
                                    haveTextFields
                                        ? "Save"
                                        : okButtonName ?? "Ok",
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 0.5,
                              height: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                            Expanded(
                              child: InkWell(
                                highlightColor: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(18)),
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(18),
                                      ),
                                    ),
                                    height: 50,
                                    child: Text("Cancel")),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
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
