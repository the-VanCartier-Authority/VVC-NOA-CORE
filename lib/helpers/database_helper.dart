import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vvc_chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        sender TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS messages');
      await _createDB(db, newVersion);
    }
  }

  Future<void> createSession(String id, String title) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('sessions', {
      'id': id,
      'title': title,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final db = await instance.database;
    return await db.query('sessions', orderBy: 'updated_at DESC');
  }

  Future<List<Map<String, dynamic>>> getMessages(String sessionId) async {
    final db = await instance.database;
    return await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> insertMessage(String sessionId, String sender, String text) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('messages', {
      'session_id': sessionId,
      'sender': sender,
      'text': text,
      'timestamp': now,
    });
    await db.update(
      'sessions',
      {'updated_at': now},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}

  // --- ELIMINACIÓN DE SESIONES ---
  Future<void> deleteSession(String sessionId) async {
    final db = await instance.database;
    // La eliminación en 'messages' se ejecuta automáticamente por ON DELETE CASCADE
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

