import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wisebu/data/CategoriesByMonth.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';

class AllRecordsScreen extends StatefulWidget {
  final List<Category> fullDataList;

  const AllRecordsScreen({@required this.fullDataList});

  @override
  State<AllRecordsScreen> createState() => _AllRecordsScreenState();
}

class _AllRecordsScreenState extends State<AllRecordsScreen> {
  List<Category> categoryList;
  List<CategoriesByMonth> categoriesByMonthList;
  final dateFormat = DateFormat("MMMM  yyyy");

  @override
  void initState() {
    categoryList = widget?.fullDataList ?? [];
    categoryList.sort((a, b) => b.date.compareTo(a.date));
    categoriesByMonthList = categoriesByMonth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All records")),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          for (CategoriesByMonth c in categoriesByMonthList) recordWidget(categoryByMonth: c),
        ],
      ),
    );
  }

  Widget recordWidget({@required CategoriesByMonth categoryByMonth}) {
    List<Category> incomes = categoryByMonth.monthCategories.where((element) => element.type == incomeType).toList();
    List<Category> expenses = categoryByMonth.monthCategories.where((element) => element.type == expenseType).toList();
    double totalIncomes = 0;
    double totalExpenses = 0;
    incomes.forEach((element) => totalIncomes += element.amount);
    expenses.forEach((element) => totalExpenses += element.amount);

    return Padding(
      padding: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                dateFormat.format(categoryByMonth.firstDateMonth),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          Text("Incomes: ${totalIncomes.toStringAsFixed(2)} eur, Expenses: ${totalExpenses.toStringAsFixed(2)} eur"),
          for (Category category in categoryByMonth.monthCategories)
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                color: category.type == incomeType ? Colors.yellow : Colors.blue,
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              child: Wrap(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${category.title} - ${category.amount}",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  if (category.description != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${category.description}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${category.date}",
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<CategoriesByMonth> categoriesByMonth() {
    List<CategoriesByMonth> finalList = [];
    List<Category> tempCategoryList = [];
    int index = 0;
    for (Category c in categoryList) {
      if (index == 0) {
        tempCategoryList.add(c);
      } else {
        DateTime currentCategoryDate = DateTime(DateTime.parse(c.date).year, DateTime.parse(c.date).month, 1);
        DateTime prevCategoryDate = DateTime(
          DateTime.parse(categoryList[index - 1].date).year,
          DateTime.parse(categoryList[index - 1].date).month,
          1,
        );

        if (currentCategoryDate.isAtSameMomentAs(prevCategoryDate)) {
          tempCategoryList.add(c);
        } else {
          finalList.add(CategoriesByMonth(firstDateMonth: prevCategoryDate, monthCategories: tempCategoryList));
          tempCategoryList = [c];
        }
      }
      index += 1;
    }

    finalList.forEach((element) => element.monthCategories.sort((a, b) => b.type.compareTo(a.type)));
    return finalList;
  }
}
