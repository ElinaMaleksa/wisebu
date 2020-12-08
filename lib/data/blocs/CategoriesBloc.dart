import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';

class CategoriesBloc implements BlocBase {
  // read all categories from db
  final categoriesController = StreamController<List<Category>>.broadcast();

  StreamSink<List<Category>> get inCategories => categoriesController.sink;

  Stream<List<Category>> get categories => categoriesController.stream;

  // add new category
  final addCategoryController = StreamController<Category>.broadcast();

  StreamSink<Category> get inAddCategory => addCategoryController.sink;

  // save category
  final updateCategoryController = StreamController<Category>.broadcast();

  StreamSink<Category> get inUpdateCategory => updateCategoryController.sink;

  // delete category
  final deleteCategoryController = StreamController<int>.broadcast();

  StreamSink<int> get inDeleteCategory => deleteCategoryController.sink;

  CategoriesBloc() {
    getCategories();
    addCategoryController.stream.listen(handleAddNewCategory);
    updateCategoryController.stream.listen(handleUpdateCategory);
    deleteCategoryController.stream.listen(handleDeleteOneRecord);
  }

  @override
  void dispose() {
    categoriesController.close();
    addCategoryController.close();
    updateCategoryController.close();
    deleteCategoryController.close();
  }

  void getCategories() async {
    List<Category> categories = await DatabaseHelper.db.getCategories();
    inCategories.add(categories);
  }

  void handleAddNewCategory(Category category) async {
    await DatabaseHelper.db.newCategory(category);
    getCategories();
  }

  void handleUpdateCategory(Category category) async {
    await DatabaseHelper.db.updateCategory(category);
    getCategories();
  }

  void handleDeleteOneRecord(int id) async {
    await DatabaseHelper.db.deleteCategory(id);
    getCategories();
  }

  void handleDeleteExpenseRecords(
      {@required String title,
      @required String type,
      @required String date}) async {
    await DatabaseHelper.db
        .dbDeleteExpense(title: title, type: type, date: date);
    getCategories();
  }
}
