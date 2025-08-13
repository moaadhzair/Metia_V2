import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:metia/data/user/user_data.dart';
import 'log_entry.dart';

class Logger {
  static Future<void> log(String message, {String level = 'INFO', String? details}) async {
    final entry = LogEntry()
      ..timestamp = DateTime.now()
      ..level = level
      ..message = message
      ..details = details;
    await UserData.isar.writeTxn(() async {
      await UserData.isar.logEntrys.put(entry);
    });
    debugPrint(message);
  }

  static Future<List<LogEntry>> getLogs({int limit = 100}) async {
    return await UserData.isar.logEntrys.where().sortByTimestampDesc().limit(limit).findAll();
  }
}
