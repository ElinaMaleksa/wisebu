import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisebu/data/Category.dart';

final String addExpensesTitle = "Create expense\'s categories";
final String addIncomesTitle = "Add incomes for current month";

final String expenseType = "Expense";
final String incomeType = "Income";

List<Category> incomes = [
  Category(
    title: "Salary",
    type: incomeType,
    doShow: 0,
  ),
  Category(
    title: "Scholarship",
    type: incomeType,
    doShow: 0,
  ),
];

List<Category> expenses = [
  Category(
    title: "Home/rent",
    type: expenseType,
    doShow: 0,
  ),
  Category(
    title: "Groceries",
    type: expenseType,
    doShow: 0,
  ),
  Category(
    title: "Groceries",
    type: expenseType,
    doShow: 0,
  ),
  Category(
    title: "Transportation",
    type: expenseType,
    doShow: 0,
  ),
  Category(
    title: "Entertainment",
    type: expenseType,
    doShow: 0,
  ),
  Category(
    title: "Bills",
    type: expenseType,
    doShow: 0,
  ),
];

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
    @required onPressed,
    @required bool showIcon}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[350],
          width: 1,
        ),
      ),
    ),
    child: ListTile(
      visualDensity: VisualDensity(vertical: -2),
      contentPadding: EdgeInsets.only(left: 0, right: 0),
      title: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 6,
              child: FittedBox(
                child: Text(
                  moneyAmount,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Spacer(),
            Flexible(
              flex: 4,
              child: showIcon
                  ? IconButton(
                      visualDensity: VisualDensity(horizontal: -4),
                      onPressed: onPressed,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: color,
                        size: 35,
                      ),
                    )
                  : Container(),
            ),
          ],
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

Future<dynamic> alertDialog({
  @required BuildContext context,
  @required onPressedOk,
  String title,
  String categoryName,
  String labelText,
  @required TextEditingController titleController,
  @required TextEditingController amountController,
}) {
  return showDialog(
    context: context,
    child: AlertDialog(
      title: Text(title ?? ""),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: labelText ?? "",
                ),
                maxLength: 30,
              ),
            ),
            Flexible(
              flex: 5,
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: "Amount",
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
