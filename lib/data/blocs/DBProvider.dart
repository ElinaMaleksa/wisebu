import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wisebu/data/Category.dart';

class DBProvider {
  // Create a singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    // Get the location of our apps directory. This is where files for our app, and only our app, are stored.
    // Files in this directory are deleted when the app is deleted.
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'app.db');

    return await openDatabase(path, version: 1, onOpen: (db) async {},
        onCreate: (Database db, int version) async {
      // Create the note table
      await db.execute('''
				CREATE TABLE note(
					id INTEGER PRIMARY KEY,
					contents TEXT DEFAULT ''
				)
			''');
    });
  }

  /*
	 * Note Table
	 */
  newCategory(Category category) async {
    final db = await database;
    var res = await db.insert('categories', category.categoryToMap());

    return res;
  }

  getCategories() async {
    final db = await database;
    var res = await db.query('categories');
    List<Category> categories =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];

    return categories;
  }

  getCategory(int id) async {
    final db = await database;
    var res = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Category.fromMap(res.first) : null;
  }

  updateCategory(Category category) async {
    final db = await database;
    var res = await db.update('categories', category.categoryToMap(),
        where: 'id = ?', whereArgs: [category.id]);

    return res;
  }

  deleteCategory(int id) async {
    final db = await database;

    db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
