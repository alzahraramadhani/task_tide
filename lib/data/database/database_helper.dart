import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasktide.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Aktifkan batasan Foreign Key di SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }


  Future _createDB(Database db, int version) async {
    // 1. Tabel Kategori Tugas
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 2. Tabel Tipe Aktivitas (Dinamis)
    await db.execute('''
      CREATE TABLE activity_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // 3. Tabel Utama Tugas Kuliah
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        difficulty_level TEXT NOT NULL,
        priority_score REAL DEFAULT 0.0,
        deadline TEXT NOT NULL,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    // 4. Tabel Aktivitas Non-Tugas
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        activity_type_id INTEGER NOT NULL,
        activity_date TEXT NOT NULL,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (activity_type_id) REFERENCES activity_types(id) ON DELETE RESTRICT
      )
    ''');

    // DEBUG TRIGGER: Berikan log ke konsol saat berhasil dibuat
    print("====== DATABASE TASKTIDE BERHASIL DIINISIALISASI ======");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}