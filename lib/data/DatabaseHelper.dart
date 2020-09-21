import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wisebu/data/Category.dart';

Database db;
final databaseName = 'wisebu_db.db';
final databaseVersion = 1;
final tableCategories = 'categories';

final columnId = "id";
final columnTitle = "title";
final columnType = "type";
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
    // set the path to the database
    join(await getDatabasesPath(), databaseName),

    // when the database is first created, create a table
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

// query for  MainScreen
Future<List<Category>> dbGetCategoriesByType(String type) async {
  // Get a reference to the database
  db = await initializeDatabase();

  final List<Map<String, dynamic>> maps = await db
      .rawQuery("SELECT $columnId, $columnTitle, $columnType, $columnDate, "
          "SUM($columnAmount) AS $columnAmount "
          "FROM $tableCategories "
          "WHERE $columnType = \"$type\" "
          "GROUP BY $columnTitle");

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

// query for DetailsScreen
Future<List<Category>> dbGetRecordsByTitle(String title) async {
  db = await initializeDatabase();

  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM $tableCategories "
          "WHERE $columnTitle = \"$title\" "
          "ORDER BY $columnDate DESC");

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

Future<void> dbUpdateRecord(
    {@required int index,
    @required String title,
    @required String date,
    @required String amount}) async {
  db = await initializeDatabase();

  String whereStatement = '$columnId = ?';
  List<String> whereArgument = ['$index'];

  Map<String, dynamic> record = {
    title: title,
    date: date,
    amount: double.parse(amount)
  };

  await db.update(
    "$tableCategories",
    record,
    where: whereStatement,
    whereArgs: whereArgument,
  );
}

Future<void> dbDeleteFromFeelings({@required String title}) async {
  db = await initializeDatabase();

  await db.delete(
    '$tableCategories',
    where: "$title = ?",
    whereArgs: [title],
  );
}
