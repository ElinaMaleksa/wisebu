import 'package:flutter/cupertino.dart';

class Category {
  int id;
  String title;
  String type; // income or expense
  String date;
  double amount;
  String description;

  Category({
    this.id,
    @required this.title,
    @required this.type,
    @required this.date,
    @required this.amount,
    this.description,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map["id"],
        title: map["title"],
        type: map["type"],
        date: map["date"],
        amount: map["amount"],
        description: map["description"],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date,
      'amount': amount,
      'description': description,
    };
  }
}
