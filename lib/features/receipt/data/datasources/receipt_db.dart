import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt_model.dart';

class ReceiptDB {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), "receipts.db");

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE receipts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          store TEXT,
          total REAL,
          vat REAL,
          tax REAL,
          date TEXT,
          category TEXT
        )
        ''');
      },
    );

    return _database!;
  }

  Future insertReceipt(ReceiptModel receipt) async {
    final db = await database;

    await db.insert(
      "receipts",
      receipt.toMap(),
    );
  }

  Future<List<ReceiptModel>> getReceipts() async {
    final db = await database;

    final result = await db.query("receipts");

    return result.map((e) => ReceiptModel.fromMap(e)).toList();
  }

  Future<void> deleteReceipt(int id) async {
    final db = await database;
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }
}
