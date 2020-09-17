import 'package:flutter/cupertino.dart';

class Record {
  int id;
  int categoryId;
  String title;
  double amount;
  String date;

  Record({
    this.id,
    @required this.categoryId,
    @required this.title,
    @required this.amount,
    @required this.date,
  });

  Map<String, dynamic> recordToMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'amount': amount,
      'date': date,
    };
  }
}
