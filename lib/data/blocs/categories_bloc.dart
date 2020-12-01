import 'dart:async';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'bloc_provider.dart';

class CategoriesBloc implements BlocBase {
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final categoriesController = StreamController<List<Category>>.broadcast();

  // Input stream. We add our notes to the stream using this variable.
  StreamSink<List<Category>> get inCategories => categoriesController.sink;

  // Output stream. This one will be used within our pages to display the notes.
  Stream<List<Category>> get categories => categoriesController.stream;

  CategoriesBloc() {
    // Retrieve all the notes on initialization
    getCategories();
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    categoriesController.close();
  }

  void getCategories() async {
    // Retrieve all the notes from the database
    List<Category> categories = await getAllCategories();

    // Add all of the notes to the stream so we can grab them later from our pages
    inCategories.add(categories);
  }
}
