import 'package:flutter/cupertino.dart';

class Category {
  int id;
  String title;
  String type; // income or expense
  int doShow;

  Category({
    this.id,
    @required this.title,
    @required this.type,
    @required this.doShow,
  });

  Map<String, dynamic> categoryToMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'doShow': doShow,
    };
  }
}
