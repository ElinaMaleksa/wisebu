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

  // Create a singleton
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

  getGroupedCategories() async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT $columnId, $columnTitle, $columnType, $columnDate, $columnDescription,"
        "SUM($columnAmount) AS $columnAmount "
        "FROM $tableCategories "
        "GROUP BY $columnTitle");
    List<Category> categories =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];

    return categories;
  }

  getCategory(int id) async {
    final db = await database;
    var res = await db.query(tableCategories, where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Category.fromMap(res.first) : null;
  }

  updateCategory(Category category) async {
    final db = await database;
    var res = await db.update(tableCategories, category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);

    return res;
  }

  deleteCategory(int id) async {
    final db = await database;

    db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  newCategory(Category category) async {
    final db = await database;
    var res = await db.insert(tableCategories, category.toMap());

    return res;
  }

// query for  MainScreen
  Future<List<Category>> dbGetRecordsByType(String type, String date) async {
    // Get a reference to the database
    final db = await database;

    final List<Map<String, dynamic>> maps = await db
        .rawQuery("SELECT $columnId, $columnTitle, $columnType, $columnDate, "
            "SUM($columnAmount) AS $columnAmount "
            "FROM $tableCategories "
            "WHERE $columnType = \"$type\" "
            "AND $columnDate LIKE \"${date.substring(0, 7)}%\" "
            "GROUP BY $columnTitle");

    // Convert the List<Map<String, dynamic> into a List<Category>
    return List.generate(maps.length, (i) {
      return Category(
          id: maps[i]['$columnId'],
          title: maps[i]['$columnTitle'],
          type: maps[i]['$columnType'],
          date: maps[i]['$columnDate'],
          amount: maps[i]['$columnAmount'],
          description: maps[i]['$columnDescription']);
    });
  }

// query for DetailsScreen
  Future<List<Category>> dbGetRecordsByTitle(String title, String date) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM $tableCategories "
            "WHERE $columnTitle = \"$title\" "
            "AND $columnDate LIKE \"${date.substring(0, 7)}%\" "
            "ORDER BY $columnDate DESC");

    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['$columnId'],
        title: maps[i]['$columnTitle'],
        type: maps[i]['$columnType'],
        date: maps[i]['$columnDate'],
        amount: maps[i]['$columnAmount'],
        description: maps[i]['$columnDescription'],
      );
    });
  }

  Future<void> dbUpdateRecord(
      {@required int index,
      @required String title,
      @required double amount,
      @required String date,
      String description}) async {
    final db = await database;

    String whereStatement = '$columnId = ?';
    List<String> whereArgument = ['$index'];

    Map<String, dynamic> record = {
      columnTitle: title,
      columnAmount: amount,
      columnDescription: description ?? "",
      columnDate: date,
    };

    await db.update(
      "$tableCategories",
      record,
      where: whereStatement,
      whereArgs: whereArgument,
    );
  }

  Future<void> dbDeleteCategory(
      {@required String title,
      @required String type,
      @required String date}) async {
    final db = await database;

    await db.delete(
      '$tableCategories',
      where: "$columnTitle = ? AND $columnType = ? "
          "AND $columnDate LIKE \"${date.substring(0, 7)}%\" ",
      whereArgs: [title, type],
    );
  }

  Future<void> dbDeleteRecord({@required int id}) async {
    final db = await database;

    await db.delete(
      '$tableCategories',
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<void> dbInsertRecord(Category category) async {
    final db = await database;

    Map<String, dynamic> record = {
      '$columnTitle': category.title,
      '$columnType': category.type,
      '$columnDate': category.date,
      '$columnAmount': category.amount,
      '$columnDescription': category.description ?? ""
    };

    await db.insert(
      '$tableCategories',
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
