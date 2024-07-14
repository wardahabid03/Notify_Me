import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  late Database _database;

  DatabaseHelper._(); // private constructor

  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'notify_me.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notifications(id INTEGER PRIMARY KEY, title TEXT, body TEXT, datetime TEXT)",
        );
      },
      version: 1,
    );
  }


  Future<List<Map<String, dynamic>>> queryAllNotifications() async {
    await initializeDatabase(); // Ensure database is initialized
    return await _database.query('notifications');
  }

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    return await _database.insert('notifications', notification);
  }

  Future<int> updateNotification(Map<String, dynamic> notification) async {
    return await _database.update(
      'notifications',
      notification,
      where: 'id = ?',
      whereArgs: [notification['id']],
    );
  }
  Future<int> deleteNotification(int id) async {
    await initializeDatabase(); // Ensure database is initialized
    return await _database.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
