import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wisebu/data/Category.dart';

Database db;
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

void createDb(Database db, int version) {
  if (version == 1) db.execute('''
        CREATE TABLE $tableCategories(
        $columnId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        $columnTitle TEXT NOT NULL, 
        $columnType TEXT NOT NULL, 
        $columnDate TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDescription TEXT
        )
       ''');
}

// upgrade database table
void upgradeDb(Database db, int oldVersion, int newVersion) {
  // add column "description" on second db version
  if (oldVersion == firstDatabaseVersion)
    db.execute(
        "ALTER TABLE $tableCategories ADD COLUMN $columnDescription TEXT");
}

Future<Database> initializeDatabase() async {
  var database = await openDatabase(
    // set the path to the database
    join(await getDatabasesPath(), databaseName),

    // when the database is first created, create a table
    onCreate: (db, version) => createDb(db, version),
    // upgrade database
    onUpgrade: (db, version, newVersion) => upgradeDb(db, version, newVersion),
    version: secondDatabaseVersion,
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
Future<List<Category>> dbGetRecordsByType(String type, String date) async {
  // Get a reference to the database
  db = await initializeDatabase();

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
  db = await initializeDatabase();

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
  db = await initializeDatabase();

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
  db = await initializeDatabase();

  await db.delete(
    '$tableCategories',
    where: "$columnTitle = ? AND $columnType = ? "
        "AND $columnDate LIKE \"${date.substring(0, 7)}%\" ",
    whereArgs: [title, type],
  );
}

Future<void> dbDeleteRecord({@required int id}) async {
  db = await initializeDatabase();

  await db.delete(
    '$tableCategories',
    where: "$columnId = ?",
    whereArgs: [id],
  );
}

Future<void> dbInsertRecord(Category category) async {
  db = await initializeDatabase();

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
