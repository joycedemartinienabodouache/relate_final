import 'package:flutter/material.dart';
import 'package:relate/models/log.dart';
import 'package:relate/resources/local_db/db/hive_methods.dart';
import 'package:relate/resources/local_db/db/sql_methods.dart';

class LogRepository{


  // static
  static var dbObject;
  static bool isHive;


  static init({@required bool isHive, @required String dbName}){
    dbObject = isHive ? HiveMethods() : SqlMethods();
    dbObject.openDb(dbName);
    dbObject.init();
  }

  static addLogs (Log log) => dbObject.addLogs(log);

  static deleteLogs (int logId) => dbObject.deleteLogs(logId);

  static getLogs() => dbObject.getLogs();

  static close() => dbObject.close();

}