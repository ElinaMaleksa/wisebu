import 'package:flutter/cupertino.dart';
import 'package:wisebu/widgets/Widgets.dart';

import 'Category.dart';

final String addExpensesTitle = "Add current expenses";
final String addIncomesTitle = "Add incomes for current month";
final String expenseDialogTitle = "Add new expense category";
final String incomeDialogTitle = "Add new income category";

final String expenseType = "Expense";
final String incomeType = "Income";

DateTime dateWithZeroTime(DateTime date) {
  return DateTime(date.year, date.month, date.day, 0, 0, 0);
}

bool doExist(
    {@required String title,
    @required String type,
    @required List<Category> itemsList}) {
  bool doExist;
  itemsList.forEach((item) {
    // trimRight() removes whitespaces from end, trimLeft() - from start
    if (item.title == title.trimRight().trimLeft() && item.type == type)
      doExist = true;
  });
  return doExist ?? false;
}

String titleFromDialog(String type) =>
    dialogTitleController.text.isNotEmpty ? dialogTitleController.text : type;

double amountFromDialog() => dialogAmountController.text.isNotEmpty
    ? double.parse(dialogAmountController.text)
    : 0;

List<Category> incomes = [
  Category(
      title: "Salary",
      type: incomeType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
  Category(
      title: "Scholarship",
      type: incomeType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
];

List<Category> expenses = [
  Category(
      title: "Home/rent",
      type: expenseType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
  Category(
      title: "Groceries",
      type: expenseType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
  Category(
      title: "Transportation",
      type: expenseType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
  Category(
      title: "Entertainment",
      type: expenseType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
  Category(
      title: "Bills",
      type: expenseType,
      date: dateWithZeroTime(DateTime.now()).toString(),
      amount: 0),
];
