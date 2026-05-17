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
      version: 2,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          photo_path TEXT,
          sort_order INTEGER NOT NULL DEFAULT 0,
          has_whatsapp INTEGER NOT NULL DEFAULT 0
        )
      '''),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE contacts ADD COLUMN has_whatsapp INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
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

  Future<void> seedDemoContactsIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM contacts'));
    if (count != null && count > 0) return;

    final demos = [
      Contact(name: 'Anna', phone: '+49 89 12345678', photoPath: 'https://randomuser.me/api/portraits/women/44.jpg', sortOrder: 0),
      Contact(name: 'Thomas', phone: '+49 89 23456789', photoPath: 'https://randomuser.me/api/portraits/men/32.jpg', sortOrder: 1),
      Contact(name: 'Maria', phone: '+49 89 34567890', photoPath: 'https://randomuser.me/api/portraits/women/68.jpg', sortOrder: 2),
      Contact(name: 'Peter', phone: '+49 89 45678901', photoPath: 'https://randomuser.me/api/portraits/men/75.jpg', sortOrder: 3),
      Contact(name: 'Dr. Müller', phone: '+49 89 56789012', photoPath: 'https://randomuser.me/api/portraits/men/51.jpg', sortOrder: 4),
    ];
    for (final c in demos) {
      await db.insert('contacts', c.toMap());
    }
  }
}
