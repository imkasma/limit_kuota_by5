import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ================= INIT DATABASE =================
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('usage_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // ================= CREATE TABLE =================
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        date TEXT PRIMARY KEY,
        wifi INTEGER,
        mobile INTEGER
      )
    ''');
  }

  // ================= INSERT / UPDATE =================
  Future<void> insertOrUpdate(String date, int wifi, int mobile) async {
    final db = await instance.database;

    await db.insert('history', {
      'date': date,
      'wifi': wifi,
      'mobile': mobile,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ================= GET HISTORY =================
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;

    return await db.query('history', orderBy: 'date DESC');
  }

  // ================= GET DATA UNTUK CHART =================
  Future<List<Map<String, dynamic>>> getUsageForChart() async {
    final db = await instance.database;

    return await db.query('history', orderBy: 'date ASC');
  }

  // ================= TOTAL MOBILE =================
  Future<double> getTotalMobileUsage() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT SUM(mobile) as total FROM history',
    );

    final total = result.first['total'];

    return total == null ? 0 : (total as num).toDouble();
  }

  // ================= TOTAL WIFI =================
  Future<double> getTotalWifiUsage() async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT SUM(wifi) as total FROM history');

    final total = result.first['total'];

    return total == null ? 0 : (total as num).toDouble();
  }

  Future<List<double>> getWeeklyUsageData() async {
    final db = await instance.database;

    final result = await db.query('history', orderBy: 'date DESC', limit: 7);

    List<double> weeklyData = result.reversed.map((row) {
      return ((row['mobile'] as num).toDouble()) / (1024 * 1024 * 1024);
    }).toList();

    while (weeklyData.length < 7) {
      weeklyData.insert(0, 0);
    }

    return weeklyData;
  }

  // ================= CLEAR DATA (OPTIONAL) =================
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('history');
  }
}
