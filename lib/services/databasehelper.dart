import 'package:utswisata/models/ticket.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._myConn();
  static final DatabaseHelper instance = DatabaseHelper._myConn();
  Database?  _db;

  String ticketTable = 'ticket';
  String colId = 'id';
  String colTitle = 'title';
  String colCategory = 'category';
  String colImage = 'image';
  String colPrice = 'price';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    String dbPath = join(await getDatabasesPath(), 'my_database.db');
    final database = await openDatabase(dbPath, version: 1, onCreate: _createDb);
    return database;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $ticketTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, $colCategory TEXT, $colImage TEXT, $colPrice REAL)');
  }

  Future<List<Map<String, dynamic>>> getTicketMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(ticketTable);
    return result;
  }

  Future<int> insertTicket(Ticket ticket) async {
    Database db = await this.db;
    final int result = await db.insert(ticketTable, ticket.toMap());
    return result;
  }

  Future<int> updateTicket(Ticket ticket) async {
    Database db = await this.db;
    final int result = await db.update(ticketTable, ticket.toMap(),
        where: '$colId = ?', whereArgs: [ticket.id]);
    return result;
  }

  Future<int> deleteTicket(int id) async {
    Database db = await this.db;
    final int result =
        await db.delete(ticketTable, where: '$colId = ?', whereArgs: [id]);

    return result;
  }

Future<List<Ticket>> getTicketList() async {
    final List<Map<String, dynamic>> ticketMapList = await getTicketMapList();
    final List<Ticket> ticketList = [];
    ticketMapList.forEach((ticketMap) {
      ticketList.add(Ticket.fromMap(ticketMap));
    });
    return ticketList;
  }

  Future<Ticket> getTicketById(int ticketId) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(ticketTable, where: '$colId = ?', whereArgs: [ticketId]);

    if (maps.isNotEmpty) {
      return Ticket.fromMap(maps.first);
    }
    throw Exception('Ticket not found');
  }
}
