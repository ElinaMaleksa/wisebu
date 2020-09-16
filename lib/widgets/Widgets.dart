import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';

final String addExpensesTitle = "Create expense\'s categories";
final String addIncomesTitle = "Add incomes for current month";

final String expenseType = "Expense";
final String incomeType = "Income";

List<Category> incomes = [
  Category(title: "Salary", type: incomeType, value: 20, doShow: false),
  Category(title: "Scholarship", type: incomeType, value: 99.60, doShow: false),
];

List<Category> expenses = [
  Category(title: "Home/rent", type: expenseType, value: 0, doShow: false),
  Category(title: "Groceries", type: expenseType, value: 0, doShow: false),
  Category(title: "Transportation", type: expenseType, value: 0, doShow: false),
  Category(title: "Entertainment", type: expenseType, value: 0, doShow: false),
  Category(title: "Bills", type: expenseType, value: 0, doShow: false),
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

Widget listTile(
    {@required BuildContext context,
    @required String title,
    @required String moneyAmount,
    @required Color color,
    @required onChanged,
    @required bool value}) {
  return ListTile(
    visualDensity: VisualDensity(horizontal: -4, vertical: 0),
    contentPadding: EdgeInsets.only(left: 0.0, right: 15),
    title: Text(
      title,
      style: TextStyle(fontSize: 18),
    ),
    leading: Container(
      color: color,
      width: 20,
    ),
    trailing: SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 8,
            child: FittedBox(
              child: Text(
                moneyAmount,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 2,
            child: CircularCheckBox(
              onChanged: onChanged,
              value: value,
              activeColor: color,
            ),
          ),
        ],
      ),
    ),
  );
}
