import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart'; // For asset loading
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final String _dbName = 'web.sqlite';
  static final int _dbVersion = 1;
  static Database? _database;

  // Table names for new features
  static const String bookmarksTable = 'bookmarks';
  static const String highlightsTable = 'highlights';
  static const String notesTable = 'notes';



  // Column names for bookmarks table
  static const String bookmarkId = 'id';
  static const String bookmarkVerseId = 'verse_id';
  static const String bookmarkTimestamp = 'timestamp';
  static const String bookmarkUserId = 'user_id';
  static const String bookmarkPinned = 'pinned';

  // Column names for highlights table
  static const String highlightId = 'id';
  static const String highlightVerseId = 'verse_id';
  static const String highlightColor = 'color';
  static const String highlightTimestamp = 'timestamp';
  static const String highlightUserId = 'user_id';
  static const String highlightPinned = 'pinned';


  // Column names for notes table
  static const String noteId = 'id';
  static const String noteVerseId = 'verse_id';
  static const String noteText = 'note';
  static const String noteTimestamp = 'timestamp';
  static const String noteUserId = 'user_id';
  static const String notePinned = 'pinned';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // A static map to convert book numbers to their names.
  static const Map<int, String> bookNames = {
    1: "Genesis",
    2: "Exodus",
    3: "Leviticus",
    4: "Numbers",
    5: "Deuteronomy",
    6: "Joshua",
    7: "Judges",
    8: "Ruth",
    9: "1 Samuel",
    10: "2 Samuel",
    11: "1 Kings",
    12: "2 Kings",
    13: "1 Chronicles",
    14: "2 Chronicles",
    15: "Ezra",
    16: "Nehemiah",
    17: "Esther",
    18: "Job",
    19: "Psalm",
    20: "Proverbs",
    21: "Ecclesiastes",
    22: "Song of Solomon",
    23: "Isaiah",
    24: "Jeremiah",
    25: "Lamentations",
    26: "Ezekiel",
    27: "Daniel",
    28: "Hosea",
    29: "Joel",
    30: "Amos",
    31: "Obadiah",
    32: "Jonah",
    33: "Micah",
    34: "Nahum",
    35: "Habakkuk",
    36: "Zephaniah",
    37: "Haggai",
    38: "Zechariah",
    39: "Malachi",
    40: "Matthew",
    41: "Mark",
    42: "Luke",
    43: "John",
    44: "Acts",
    45: "Romans",
    46: "1 Corinthians",
    47: "2 Corinthians",
    48: "Galatians",
    49: "Ephesians",
    50: "Philippians",
    51: "Colossians",
    52: "1 Thessalonians",
    53: "2 Thessalonians",
    54: "1 Timothy",
    55: "2 Timothy",
    56: "Titus",
    57: "Philemon",
    58: "Hebrews",
    59: "James",
    60: "1 Peter",
    61: "2 Peter",
    62: "1 John",
    63: "2 John",
    64: "3 John",
    65: "Jude",
    66: "Revelation",
  };

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, _dbName);

    // Copy the database from assets if it doesn't exist in the internal storage.
    if (!await File(dbPath).exists()) {
      ByteData data = await rootBundle.load('assets/db/web.sqlite');
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
      print('Database copied to $dbPath');
    }

    return await openDatabase(dbPath, version: _dbVersion, onUpgrade: _onUpgrade, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Create bookmarks table
    await db.execute('''
      CREATE TABLE $bookmarksTable (
        $bookmarkId INTEGER PRIMARY KEY AUTOINCREMENT,
        $bookmarkVerseId INTEGER NOT NULL,
        $bookmarkTimestamp INTEGER NOT NULL,
        $bookmarkUserId TEXT,
        $bookmarkPinned INTEGER DEFAULT 0,
        'type' TEXT DEFAULT 'bookmark',
        FOREIGN KEY ($bookmarkVerseId) REFERENCES verses(id)
      )
    ''');

    // Create highlights table
    await db.execute('''
      CREATE TABLE $highlightsTable (
        $highlightId INTEGER PRIMARY KEY AUTOINCREMENT,
        $highlightVerseId INTEGER NOT NULL,
        $highlightColor TEXT NOT NULL,
        $highlightTimestamp INTEGER NOT NULL,
        $highlightUserId TEXT,
        $highlightPinned INTEGER DEFAULT 0,
        'type' TEXT DEFAULT 'highlight',
        FOREIGN KEY ($highlightVerseId) REFERENCES verses(id)
      )
    ''');

    // Create notes table
    await db.execute('''
      CREATE TABLE $notesTable (
        $noteId INTEGER PRIMARY KEY AUTOINCREMENT,
        $noteVerseId INTEGER NOT NULL,
        $noteText TEXT NOT NULL,
        $noteTimestamp INTEGER NOT NULL,
        $noteUserId TEXT,
        $notePinned INTEGER DEFAULT 0,
        'type' TEXT DEFAULT 'note',
        FOREIGN KEY ($noteVerseId) REFERENCES verses(id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _onCreate(db, newVersion);
    }
  }

  // Helper methods for bookmarks
  Future<int> insertBookmark(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(bookmarksTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllBookmarks() async {
    Database db = await instance.database;
    return await db.query(bookmarksTable);
  }

  Future<int> deleteBookmark(int id) async {
    Database db = await instance.database;
    return await db.delete(bookmarksTable, where: '$bookmarkVerseId = ?', whereArgs: [id]);
  }

  // Helper methods for highlights
  Future<int> insertHighlight(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(highlightsTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllHighlights() async {
    Database db = await instance.database;
    return await db.query(highlightsTable);
  }

  Future<int> deleteHighlight(int id) async {
    Database db = await instance.database;
    return await db.delete(highlightsTable, where: '$highlightId = ?', whereArgs: [id]);
  }

  // Helper methods for notes
  Future<int> insertNote(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(notesTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllNotes() async {
    Database db = await instance.database;
    return await db.query(notesTable);
  }

  Future<int> getNoteCount(int verseId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.rawQuery('SELECT COUNT(*) FROM $notesTable WHERE $noteVerseId = ?', [verseId]);
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> deleteNote(int id) async {
    Database db = await instance.database;
    return await db.delete(notesTable, where: '$noteId = ?', whereArgs: [id]);
  }

  /// **Retrieve book, chapter, and verse info from `verseId`**
  static Future<Map<String, dynamic>?> getVerseDetails(int verseId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      'verses',
      columns: ['book', 'chapter', 'verse', 'text'],
      where: 'id = ?',
      whereArgs: [verseId],
    );

    if (results.isNotEmpty) {
      var row = results.first;
      return {
        "bookName": bookNames[row['book']] ?? "Unknown",
        "chapter": row['chapter'],
        "verse": row['verse'],
        "text": row['text'],
      };
    }
    return null;
  }

  /// **Toggle pinned state for a saved item**
  static Future<void> togglePin(String table, int verseId, bool isPinned) async {
    final db = await instance.database;
    await db.update(
      table,
      {'pinned': isPinned ? 1 : 0},
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
  }

  /// **Retrieve all saved items with proper references**
  static Future<List<Map<String, dynamic>>> getSavedItems(String table) async {
    final db = await instance.database;
    List<Map<String, dynamic>> items = await db.query(
      table,
      orderBy: 'pinned DESC, timestamp DESC',
    );

    List<Map<String, dynamic>> enrichedItems = [];
    for (var item in items) {
      var details = await getVerseDetails(item['verse_id']);
      if (details != null) {
        enrichedItems.add({...item, ...details}); // ✅ Creates a new mutable map
      } else {
        enrichedItems.add({...item}); // ✅ Ensures all items are mutable
      }
    }

    return items;
  }

  /// Returns a list of books for a given testament.
  /// [testament] should be "OT" (Old Testament) or "NT" (New Testament).
  Future<List<Map<String, dynamic>>> getBooks(String testament) async {
    final db = await database;
    // Query distinct book numbers from the verses table.
    List<Map<String, dynamic>> results =
    await db.rawQuery('SELECT DISTINCT book FROM verses');

    // Filter and sort the results.
    List<int> bookNumbers = results
        .map((row) => row['book'] as int)
        .where((book) =>
    testament.toUpperCase() == "OT" ? book <= 39 : book >= 40)
        .toList()
      ..sort();

    // Map the book numbers to a list of maps with id and name.
    return bookNumbers.map((book) {
      return {
        'id': book,
        'name': bookNames[book] ?? 'Book $book',
      };
    }).toList();
  }

  /// Returns a list of distinct chapter numbers for a given book.
  Future<List<int>> getChaptersForBook(int book) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT DISTINCT chapter FROM verses WHERE book = ? ORDER BY chapter',
        [book]);

    return results.map((row) => row['chapter'] as int).toList();
  }

  /// Returns a list of verses for a given book and chapter.
  Future<List<Map<String, dynamic>>> getVerses(int book, int chapter) async {
    final db = await database;
    return await db.query(
      'verses',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
      orderBy: 'verse',
    );
  }
}
