import 'package:flutter/cupertino.dart';

class Category {
  int id;
  String title;
  String type; // income or expense
  String date;
  double amount;

  Category({
    this.id,
    @required this.title,
    @required this.type,
    @required this.date,
    @required this.amount,
  });

  Map<String, dynamic> categoryToMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date,
      'amount': amount,
    };
  }
}
