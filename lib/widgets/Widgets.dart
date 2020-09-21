import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextEditingController dialogTitleController = TextEditingController();
TextEditingController dialogAmountController = TextEditingController();

Widget yellowButton(
    {@required BuildContext context,
    @required onPressed,
    @required String text,
    bool isLarge}) {
  if (isLarge == null) isLarge = false;
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.09,
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

Widget listTileMainScreen(
    {@required BuildContext context,
    @required String title,
    @required String moneyAmount,
    @required Color color,
    @required onTitlePressed,
    @required onLongPressed,
    onIconPressed,
    @required bool isExpense}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[350],
          width: 1,
        ),
      ),
    ),
    child: InkWell(
      onTap: isExpense ? null : onTitlePressed,
      onLongPress: isExpense ? null : onLongPressed,
      child: ListTile(
        visualDensity: VisualDensity(vertical: -2),
        contentPadding: EdgeInsets.only(left: 5, right: 5),
        title: InkWell(
          onTap: isExpense ? onTitlePressed : null,
          onLongPress: isExpense ? onLongPressed : null,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 6,
                  child: FittedBox(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: FittedBox(
                    child: Text(
                      moneyAmount,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: isExpense
              ? IconButton(
                  visualDensity: VisualDensity(horizontal: -4),
                  onPressed: isExpense ? onIconPressed : null,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: color,
                    size: 35,
                  ),
                )
              : Container(),
        ),
      ),
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
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    ),
  );
}

Widget addNewItem(
    {@required String text, @required Color color, @required onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: ListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.grey[500]),
        ),
        trailing: Icon(Icons.add_circle, size: 35, color: color)),
  );
}

Future<dynamic> alertDialogFields(
    {@required BuildContext context,
    @required onPressedOk,
    String title,
    String hintText,
    @required TextEditingController titleController,
    @required TextEditingController amountController}) {
  return showDialog(
    context: context,
    child: AlertDialog(
      title: Text(title ?? "", style: TextStyle(fontSize: 18)),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: hintText ?? "",
                ),
                maxLength: 30,
              ),
            ),
            Flexible(
              flex: 5,
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                    hintText: "Amount",
                    suffixIcon: Icon(Icons.euro_symbol, size: 15)),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
      ),
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

Future<dynamic> alertDialogDelete(
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
