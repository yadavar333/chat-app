import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/message.dart';

class DBHelper {
  static const _dbName = 'chat_app.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        avatar_color INTEGER NOT NULL DEFAULT ${0xFF6366F1},
        created_at   TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id  INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
        text        TEXT    NOT NULL,
        is_from_me  INTEGER NOT NULL DEFAULT 0,
        is_read     INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_messages_contact_id ON messages (contact_id)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_created_at ON messages (created_at)',
    );
  }

  // ── Contacts ──────────────────────────────────────────────────────────────

  static Future<List<Contact>> getContacts() async {
    final db = await database;
    // Join to fetch last message + unread count in one query
    final rows = await db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.avatar_color,
        c.created_at,
        m.text        AS last_message_text,
        m.created_at  AS last_message_at,
        (SELECT COUNT(*) FROM messages
         WHERE contact_id = c.id AND is_read = 0 AND is_from_me = 0
        ) AS unread_count
      FROM contacts c
      LEFT JOIN messages m ON m.id = (
        SELECT id FROM messages
        WHERE contact_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
      )
      ORDER BY COALESCE(m.created_at, c.created_at) DESC
    ''');
    return rows.map(Contact.fromMap).toList();
  }

  static Future<int> insertContact(Contact contact) async {
    final db = await database;
    return db.insert('contacts', contact.toMap());
  }

  static Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  static Future<List<Message>> getMessages(int contactId) async {
    final db = await database;
    final rows = await db.query(
      'messages',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Message.fromMap).toList();
  }

  static Future<int> insertMessage(Message message) async {
    final db = await database;
    return db.insert('messages', message.toMap());
  }

  static Future<void> markMessagesAsRead(int contactId) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'contact_id = ? AND is_from_me = 0 AND is_read = 0',
      whereArgs: [contactId],
    );
  }

  // ── Full-text search ──────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> searchMessages(String query) async {
    final db = await database;
    final term = '%${query.toLowerCase()}%';
    return db.rawQuery('''
      SELECT m.*, c.name AS contact_name
      FROM messages m
      JOIN contacts c ON c.id = m.contact_id
      WHERE LOWER(m.text) LIKE ?
      ORDER BY m.created_at DESC
      LIMIT 50
    ''', [term]);
  }
}
