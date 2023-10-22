import 'dart:async';

import 'package:gastos/utils/Constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _db;

  static String tableUser = "user";
  static String tableMovement = "movement";
  static String tableCategory = "category";

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, Constants.db_name);
    _db = await openDatabase(
      path,
      version: Constants.db_version,
      onCreate: _onCreate,
      onUpgrade: _onUpdate,
      onConfigure: _onConfigure,
      onDowngrade: (db, oldVersion, newVersion) {
        
      },
    );
  }

  FutureOr<void> _onCreate(Database db, int version) {
    db.execute('''CREATE TABLE $tableUser 
      (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, amountTotal REAL NOT NULL); 
      ''');
    db.execute('''
        CREATE TABLE $tableMovement 
        (id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, description TEXT, idCategory INTEGER, FOREIGN KEY(idCategory) REFERENCES $tableCategory(id) ON DELETE NO ACTION ON UPDATE NO ACTION);
      ''');
    db.execute('''CREATE TABLE $tableCategory 
      (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL); 
      ''');
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
}
  FutureOr<void> _onUpdate(Database db, int oldVersion, int newVersion) {
    if (oldVersion == 1) {
      db.execute('DROP TABLE IF EXISTS $tableCategory');
      db.execute('''CREATE TABLE $tableCategory 
      (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL); 
      ''');
      db.execute('ALTER TABLE $tableMovement ADD description TEXT');
      db.execute('ALTER TABLE $tableMovement ADD idCategory INTEGER REFERENCES $tableCategory(id) ON DELETE NO ACTION ON UPDATE NO ACTION');
    }
  }

  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    return await _db?.insert(tableName, row) ?? 0;
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    return await _db?.query(table) ?? List.empty();
  }

  Future<int> queryRowCount(String table) async {
    final results =
        await _db?.rawQuery('SELECT COUNT(*) FROM $table') ?? List.empty();
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row, String table) async {
    int id = row['id'];
    return await _db?.update(
          table,
          row,
          where: 'id = ?',
          whereArgs: [id],
        ) ??
        0;
  }

  Future<int> delete(int id, String table) async {
    return await _db?.delete(
          table,
          where: 'id = ?',
          whereArgs: [id],
        ) ??
        0;
  }
}
