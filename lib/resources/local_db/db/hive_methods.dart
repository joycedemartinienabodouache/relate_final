import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relate/models/log.dart';
import 'package:relate/resources/local_db/interface/log_interface.dart';

class HiveMethods implements LogInterface{

  String hiveBox ;

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  @override
  openDb(dbName) => (hiveBox = dbName);

  @override
  addLogs(Log log) async {
    var box = await Hive.openBox(hiveBox);
    //
    // if (Hive.isBoxOpen(hiveBox)){
    //   box = Hive.box(hiveBox);
    // }else{
    //   box = await Hive.openBox(hiveBox);
    // }

    var logMap = log.toMap(log);
    int idOfInput = await box.add(logMap);
    // box.put(key, value)
    close();

    return idOfInput;
  }

  updateLogs(int i, Log newLog ) async { //not used
    var box = await Hive.openBox(hiveBox);

    var newLogMap = newLog.toMap(newLog);
    box.putAt(i, newLogMap);

    close();
  }

  @override
  close() => Hive.close();

  @override
  deleteLogs(int logId) async {

    var box = await Hive.openBox(hiveBox);

    await box.deleteAt(logId);
    // await box.delete(logId);

    box.close();
  }

  @override
  Future<List<Log>> getLogs() async {

    var box = await Hive.openBox(hiveBox);

    List<Log> logList = [];

    for(int i; i < box.length ; i++ ){

      var logMap = box.getAt(i);
      logList.add(Log.fromMap(logMap));

    }
    return logList;

  }




}