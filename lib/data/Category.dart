import 'package:flutter/cupertino.dart';

class Category {
  String title;
  String type; // income or expense
  double value;
  bool doShow;

  Category({
    @required this.title,
    @required this.type,
    @required this.value,
    @required this.doShow,
  });
}
