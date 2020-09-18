import 'Category.dart';

final String addExpensesTitle = "Add current expenses";
final String addIncomesTitle = "Add incomes for current month";

final String expenseType = "Expense";
final String incomeType = "Income";

DateTime dateWithZeroTime(DateTime date) {
  return DateTime(date.year, date.month, date.day, 0, 0, 0);
}

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
