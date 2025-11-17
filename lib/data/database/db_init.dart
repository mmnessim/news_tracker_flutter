import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final _dbName = 'app.db';
  static final _dbVersion = 1;

  static final table = 'terms';
  static final columnId = 'id';
  static final columnTerm = 'term';
  static final columnLocked = 'locked';

  AppDatabase._privateConstruct();

  static final AppDatabase instance = AppDatabase._privateConstruct();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $table (
          $columnId INTEGER PRIMARY KEY,
          $columnTerm TEXT NOT NULL,
          $columnLocked INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  void close() {
    if (_database == null) return;
    _database!.close();
  }

  Future<int> insert(int id, String term, bool locked) async {
    final db = await database;
    return await db.insert(table, {
      columnId: id,
      columnTerm: term,
      columnLocked: locked ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getAll() async {
    final db = await database;
    return await db.query(table);
  }
}
