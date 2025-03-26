import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbName = 'web.sqlite';
  static final _dbVersion = 1;

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, _dbName);

    // Check if the database already exists in the app's internal storage.
    if (!await File(dbPath).exists()) {
      // Copy the database from assets to internal storage.
      ByteData data = await rootBundle.load('assets/web.sqlite');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    return await openDatabase(dbPath, version: _dbVersion);
  }

  // Fetch all books
  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await DatabaseHelper().database;
    return await db.query('books');  // Assuming the table is named 'books'
  }

  // Fetch verses in a specific chapter
  Future<List<Map<String, dynamic>>> getVerses(int chapterId) async {
    final db = await DatabaseHelper().database;
    return await db.query('verses', where: 'chapter_id = ?', whereArgs: [chapterId]);
  }

  // Fetch all chapters for a book
  Future<List<Map<String, dynamic>>> getChapters(int bookId) async {
    final db = await DatabaseHelper().database;
    return await db.query('chapters', where: 'book_id = ?', whereArgs: [bookId]);
  }

}
