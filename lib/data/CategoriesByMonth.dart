import 'package:flutter/cupertino.dart';
import 'package:wisebu/data/Category.dart';

class CategoriesByMonth {
  // the first day of the month without time
  DateTime firstDateMonth;

  // all incomes and expenses of the month
  List<Category> monthCategories;

  CategoriesByMonth({
    @required this.firstDateMonth,
    @required this.monthCategories,
  });

  Map<String, dynamic> toMap() => {
        'firstDateMonth': firstDateMonth,
        'monthCategories': recordsToJson(),
      };

  CategoriesByMonth.fromMap(Map<String, dynamic> json)
      : firstDateMonth = json['firstDateMonth'],
        monthCategories = (json['monthCategories'] as List)?.map((item) => Category.fromMap(item))?.toList();

  List<Map<String, dynamic>> recordsToJson() {
    List<Map<String, dynamic>> list = [];
    this.monthCategories.forEach((element) => list.add(element.toMap()));
    return list;
  }
}
