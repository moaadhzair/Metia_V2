import 'package:isar/isar.dart';
part 'log_entry.g.dart';

@collection
class LogEntry {
  Id id = Isar.autoIncrement;
  late DateTime timestamp;
  late String level;
  late String message;
  String? details;
}
