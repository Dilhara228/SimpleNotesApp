import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class NoteDbHelper {
  static const dbname = 'notes.db';
  static const dbversion = 1;
  static const tablename = 'notes';
  static const colid = 'id';
  static const coltittle = 'title';
  static const coldescription = 'description';
  static const coldate = 'date';

  static final NoteDbHelper instance = NoteDbHelper._privateConstructor();
  static Database? _database;

  NoteDbHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbname);
    return await openDatabase(path, version: dbversion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablename (
        $colid INTEGER PRIMARY KEY AUTOINCREMENT,
        $coltittle TEXT NOT NULL,
        $coldescription TEXT NOT NULL,
        $coldate TEXT NOT NULL
      )
    ''');
  }

  // Insert a note into the database with formatted date
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // Update date to current formatted date
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    row[coldate] = formattedDate;
    return await db.insert(tablename, row);
  }

  // Query all notes from the database
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(tablename);
  }

  // Query all notes ordered by date (ascending or descending)
  Future<List<Map<String, dynamic>>> queryAllOrdered(bool isAscending) async {
    Database db = await instance.database;
    String order = isAscending ? 'ASC' : 'DESC';
    return await db.query(tablename, orderBy: '$coldate $order');
  }

  // Search for notes based on a query (title or description)
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    Database db = await instance.database;
    return await db.query(
      tablename,
      where: '$coltittle LIKE ? OR $coldescription LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // Update a note in the database with a formatted date
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[colid];
    // Update date to current formatted date
    row[coldate] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    return await db.update(tablename, row, where: '$colid = ?', whereArgs: [id]);
  }

  // Delete a note from the database
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tablename, where: '$colid = ?', whereArgs: [id]);
  }

  // Close the database
  Future close() async {
    Database db = await instance.database;
    db.close();
  }
}
