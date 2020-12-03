import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wisebu/data/Category.dart';

class DatabaseHelper {
  final databaseName = 'wisebu_db.db';
  final firstDatabaseVersion = 1;
  final secondDatabaseVersion = 2;
  final tableCategories = 'categories';

  final columnId = "id";
  final columnTitle = "title";
  final columnType = "type";
  final columnDate = "date";
  final columnAmount = "amount";
  final columnDescription = "description";

  // create a singleton
  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();
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
    String path = join(documentsDir.path, databaseName);

    return await openDatabase(path,
        version: secondDatabaseVersion,
        onOpen: (db) async {},
        onUpgrade: (db, version, newVersion) =>
            upgradeDb(db, version, newVersion),
        onCreate: (Database db, int version) async {
          // Create the categories table
          db.execute('''
        CREATE TABLE $tableCategories(
        $columnId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        $columnTitle TEXT NOT NULL, 
        $columnType TEXT NOT NULL, 
        $columnDate TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDescription TEXT
        )
       ''');
        });
  }

  // upgrade database table
  void upgradeDb(Database db, int oldVersion, int newVersion) {
    // add column "description" on second db version
    if (oldVersion == firstDatabaseVersion)
      db.execute(
          "ALTER TABLE $tableCategories ADD COLUMN $columnDescription TEXT");
  }

  getCategories() async {
    final db = await database;
    var res = await db.query(tableCategories);
    List<Category> categories =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];

    return categories;
  }

  updateCategory(Category category) async {
    final db = await database;
    var res = await db.update(tableCategories, category.toMap(),
        where: '$columnId = ?', whereArgs: [category.id]);

    return res;
  }

  deleteCategory(int id) async {
    final db = await database;

    db.delete(tableCategories, where: '$columnId = ?', whereArgs: [id]);
  }

  newCategory(Category category) async {
    final db = await database;
    var res = await db.insert(tableCategories, category.toMap());

    return res;
  }

  // delete for all records in month with the same title
  // meant for EXPENSE delete from MainScreen
  Future<void> dbDeleteExpense(
      {@required String title,
      @required String type,
      @required String date}) async {
    final db = await database;

    db.delete(
      '$tableCategories',
      where: "$columnTitle = ? AND $columnType = ? "
          "AND $columnDate LIKE \"${date.substring(0, 7)}%\" ",
      whereArgs: [title, type],
    );
  }
}
