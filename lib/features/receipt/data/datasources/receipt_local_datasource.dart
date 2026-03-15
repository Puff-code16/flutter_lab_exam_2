import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReceiptLocalDatasource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();

    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();

    return await openDatabase(
      join(path, "receipt.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE receipts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store TEXT,
        total REAL,
        vat REAL,
        tax REAL,
        imagePath TEXT,
        date TEXT,
        category TEXT
        )
        ''');
      },
      onOpen: (db) async {
        final existingColumns =
            await db.rawQuery('PRAGMA table_info(receipts)');
        final hasTax = existingColumns.any((c) => c['name'] == 'tax');
        if (!hasTax) {
          await db.execute('ALTER TABLE receipts ADD COLUMN tax REAL');
        }

        final hasImagePath =
            existingColumns.any((c) => c['name'] == 'imagePath');
        if (!hasImagePath) {
          await db.execute('ALTER TABLE receipts ADD COLUMN imagePath TEXT');
        }
      },
    );
  }

  Future insertReceipt(Map<String, dynamic> data) async {
    final db = await database;

    await db.insert("receipts", data);
  }

  Future<void> deleteReceipt(int id) async {
    final db = await database;
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getReceipts() async {
    final db = await database;

    return await db.query("receipts");
  }
}
