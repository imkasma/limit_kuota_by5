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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ================= CREATE TABLE =================
  Future<void> _createDB(Database db, int version) async {
    // tabel riwayat penggunaan
    await db.execute('''
      CREATE TABLE history (
        date TEXT PRIMARY KEY,
        wifi INTEGER,
        mobile INTEGER
      )
    ''');

    // tabel pengaturan limit harian
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        daily_limit INTEGER
      )
    ''');

    // default limit harian = 1 GB
    await db.insert(
      'settings',
      {
        'id': 1,
        'daily_limit': 1024 * 1024 * 1024,
      },
    );
  }

  // ================= INSERT / UPDATE HISTORY =================
  Future<void> insertOrUpdate(String date, int wifi, int mobile) async {
    final db = await database;

    await db.insert(
      'history',
      {
        'date': date,
        'wifi': wifi,
        'mobile': mobile,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ================= GET HISTORY =================
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;

    return await db.query(
      'history',
      orderBy: 'date DESC',
    );
  }

  // ================= WEEKLY CHART =================
  Future<List<double>> getWeeklyUsageData() async {
    final db = await database;

    final result = await db.query(
      'history',
      orderBy: 'date DESC',
      limit: 7,
    );

    List<double> weeklyData = result.reversed.map((row) {
      final mobile = (row['mobile'] as num).toDouble();
      return mobile / (1024 * 1024 * 1024); // bytes ke GB
    }).toList();

    while (weeklyData.length < 7) {
      weeklyData.insert(0, 0);
    }

    return weeklyData;
  }

  // ================= TOTAL MOBILE =================
  Future<double> getTotalMobileUsage() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(mobile) as total FROM history',
    );

    final total = result.first['total'];
    return total == null ? 0 : (total as num).toDouble();
  }

  // ================= TOTAL WIFI =================
  Future<double> getTotalWifiUsage() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(wifi) as total FROM history',
    );

    final total = result.first['total'];
    return total == null ? 0 : (total as num).toDouble();
  }

  // ================= TOTAL PEMAKAIAN BULAN INI =================
  Future<double> getMonthlyUsage() async {
    final db = await database;

    final now = DateTime.now();
    final monthPrefix =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";

    final result = await db.rawQuery(
      "SELECT SUM(mobile) as total FROM history WHERE date LIKE '$monthPrefix%'",
    );

    final total = result.first['total'];
    return total == null ? 0 : (total as num).toDouble();
  }

  // ================= HITUNG SISA KUOTA BULAN INI =================
  Future<double> getRemainingQuota(double totalQuotaGB) async {
    double usedBytes = await getMonthlyUsage();
    double totalBytes = totalQuotaGB * 1024 * 1024 * 1024;

    double remaining = totalBytes - usedBytes;

    if (remaining < 0) remaining = 0;

    return remaining / (1024 * 1024 * 1024); // hasil GB
  }

  // ================= GET DAILY LIMIT =================
  Future<int> getDailyLimit() async {
    final db = await database;

    final result = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      return result.first['daily_limit'] as int;
    }

    return 1024 * 1024 * 1024;
  }

  // ================= UPDATE DAILY LIMIT =================
  Future<void> updateDailyLimit(int bytes) async {
    final db = await database;

    await db.update(
      'settings',
      {'daily_limit': bytes},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ================= CLEAR HISTORY =================
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('history');
  }
}