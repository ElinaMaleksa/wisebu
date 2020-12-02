import 'dart:async';

import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';

class CategoriesBloc implements BlocBase {
  final categoriesController = StreamController<List<Category>>.broadcast();

  StreamSink<List<Category>> get inCategories => categoriesController.sink;

  Stream<List<Category>> get categories => categoriesController.stream;

  final addCategoryController = StreamController<Category>.broadcast();

  StreamSink<Category> get inAddCategory => addCategoryController.sink;

  CategoriesBloc() {
    getCategories();

    addCategoryController.stream.listen(handleAddCategory);
  }

  @override
  void dispose() {
    categoriesController.close();
    addCategoryController.close();
  }

  void getCategories() async {
    List<Category> categories = await DatabaseHelper.db.getGroupedCategories();
    inCategories.add(categories);
  }

  void handleAddCategory(Category category) async {
    await DatabaseHelper.db.newCategory(category);
    getCategories();
  }
}
