import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:relate/models/log.dart';
import 'package:relate/resources/local_db/interface/log_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlMethods implements LogInterface{
  Database _db;

  String databaseName ;

  String tableName = "Call_Logs";

  //Columns
  String id = "log_id";
  String callerMame = "caller_name";
  String callerPic = "caller_pic";
  String callStatus = "call_status";
  String receiverName = "receiver_name";
  String receiverPic = "receiver_pic";
  String timestamp = "timestamp";

  Future<Database> get db async{

    if (_db != null){
      return _db;
    }
    print ("db was null, now awaiting for a new database...");
    _db = await init();
    return _db;

  }

  @override
  init() async {

    Directory dir = await getApplicationDocumentsDirectory();

    String path = join(dir.path, databaseName);

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }



  @override
  addLogs(Log log) async {
    var dbClient = await db;
    await dbClient.insert(tableName, log.toMap(log));
  }

  @override
  openDb(dbName) => (databaseName = dbName);

  @override
  deleteLogs(int logId) async {
    var dbClient = await db;
    return await dbClient.delete(tableName, where: '$id = ?', whereArgs: [logId + 1]);
  }

  @override
  Future<List<Log>> getLogs() async{

    try{
      var dbClient = await db;

      List<Map> maps = await dbClient.query(tableName,
          columns:[
            id,
            callerMame,
            callerPic,
            receiverName,
            receiverPic,
            callStatus,
            timestamp,
          ]
      );

      List<Log> logList = [];

      if ( maps.isNotEmpty ){
        for( Map map in maps ){
          logList.add(Log.fromMap(map));
        }
      }
      return logList;
    } catch (e){
      print(e);
      return null;
    }

  }


  _onCreate(Database db, int version) async {

    String createTableQuery =
        "CREATE TABLE $tableName ( "
        "$id INTEGER PRIMARY KEY,"
        " $callerMame TEXT,"
        " $callerPic TEXT,"
        " $receiverName TEXT,"
        " $receiverPic TEXT,"
        " $callStatus TEXT,"
        " $timestamp TEXT "
        ")";

    await db.execute(createTableQuery);

    print("table created");
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

