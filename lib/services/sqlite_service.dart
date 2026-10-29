import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class SqliteService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  // สร้างฐานข้อมูล SQLite ในเครื่อง
  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'study_buddy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, isSynced INTEGER)',
        );
      },
    );
  }

  // บันทึกข้อมูลลง SQLite
  Future<void> insertUser(UserModel user) async {
    final dbClient = await db;
    await dbClient.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ดึงข้อมูลที่ยังไม่ได้ซิงก์ขึ้น Firebase (isSynced = 0)
  Future<List<UserModel>> getUnsyncedUsers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'users',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // อัปเดตสถานะเมื่อซิงก์สำเร็จ (เปลี่ยนเป็น 1)
  Future<void> markAsSynced(String id) async {
    final dbClient = await db;
    await dbClient.update(
      'users',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}