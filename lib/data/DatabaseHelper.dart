import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/widgets/Widgets.dart';

Database db;
final databaseName = 'wisebu_db.db';
final databaseVersion = 1;
final tableCategories = 'categories';
final tableRecords = 'records';

final columnId = "id";
final columnTitle = "title";
final columnType = "type";
final columnDoShow = "doShow";

final columnCategoryId = "categoryId";
final columnDate = "date";
final columnAmount = "amount";

void createDb(Database db) {
  db.execute('''
        CREATE TABLE $tableCategories(
        $columnId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        $columnTitle TEXT NOT NULL, 
        $columnType TEXT NOT NULL, 
        $columnDate TEXT NOT NULL,
        $columnAmount REAL NOT NULL
        )
       ''');
}

Future<Database> initializeDatabase() async {
  var database = await openDatabase(
    // Set the path to the database
    join(await getDatabasesPath(), databaseName),

    // When the database is first created, create a tables
    onCreate: (db, version) => createDb(db),
    version: databaseVersion,
  );
  return database;
}

Future<void> dbInsertCategories(
    {@required List<Category> incomes,
    @required List<Category> expenses}) async {
  db = await initializeDatabase();
  Future<void> insertCategory(Category category) async {
    await db.insert(
      '$tableCategories',
      category.categoryToMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // insert default categories into the database
  for (var category in incomes) await insertCategory(category);
  for (var category in expenses) await insertCategory(category);
}

Future<List<Category>> dbGetCategoriesByType(String type) async {
  // Get a reference to the database
  db = await initializeDatabase();
  // Query the table for all Categories
  String whereStatement = '$columnType = ?';
  List<String> whereArgument = [type];

  final List<Map<String, dynamic>> maps = await db.query('$tableCategories',
      where: whereStatement,
      whereArgs: whereArgument,
      orderBy: "$columnDate ASC",
      groupBy: "$columnTitle");

  // Convert the List<Map<String, dynamic> into a List<Category>
  return List.generate(maps.length, (i) {
    return Category(
      id: maps[i]['$columnId'],
      title: maps[i]['$columnTitle'],
      type: maps[i]['$columnType'],
      date: maps[i]['$columnDate'],
      amount: maps[i]['$columnAmount'],
    );
  });
}

/*
SELECT sum(amount) FROM categories
WHERE title = "Groceries"
GROUP BY title*/

Future calculateTotal(String title) async {
  initializeDatabase();
  var result = await db.rawQuery(
      "SELECT SUM($columnAmount) FROM $tableCategories WHERE $columnTitle = \"$title\" AND $columnType = \"$expenseType\" GROUP BY $columnTitle");
  print(result.toList());
}
