import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';

class CategoriesBloc implements BlocBase {
  // read and group categories by title from db
  final categoriesController = StreamController<List<Category>>.broadcast();

  StreamSink<List<Category>> get inCategories => categoriesController.sink;

  Stream<List<Category>> get categories => categoriesController.stream;

  // adding new category
  final addCategoryController = StreamController<Category>.broadcast();

  StreamSink<Category> get inAddCategory => addCategoryController.sink;

  // saving category
  final updateCategoryController = StreamController<Category>.broadcast();

  StreamSink<Category> get inUpdateCategory => updateCategoryController.sink;

  // deleting category
  final deleteCategoryController = StreamController<int>.broadcast();

  StreamSink<int> get inDeleteCategory => deleteCategoryController.sink;

  // This bool StreamController will be used to ensure we don't do anything
  // else until a category is actually deleted from the database
  final categoryDeletedController = StreamController<bool>.broadcast();

  StreamSink<bool> get inDeleted => categoryDeletedController.sink;

  Stream<bool> get deleted => categoryDeletedController.stream;

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
    categoryDeletedController.close();
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
    inDeleted.add(true);
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
