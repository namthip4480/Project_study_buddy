import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/study_session.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('study_buddy.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // เพิ่มข้อมูลสถิติการอ่านหนังสือ
  Future<int> insertSession(StudySession session) async {
    final db = await instance.database;
    return await db.insert('study_sessions', session.toMap());
  }

  // ดึงสถิติการอ่านทั้งหมด
  Future<List<StudySession>> getAllSessions() async {
    final db = await instance.database;
    final result = await db.query('study_sessions', orderBy: 'id DESC');
    return result.map((json) => StudySession.fromMap(json)).toList();
  }
}
