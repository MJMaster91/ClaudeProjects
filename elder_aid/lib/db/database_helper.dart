import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'elder_aid.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          photo_path TEXT,
          sort_order INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'sort_order ASC, name ASC');
    return rows.map(Contact.fromMap).toList();
  }

  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return db.insert('contacts', contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update('contacts', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]);
  }

  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
