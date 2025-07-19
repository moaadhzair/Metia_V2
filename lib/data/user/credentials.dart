import 'package:isar/isar.dart';

part 'credentials.g.dart';

@collection
class UserCredentials {
  Id id = Isar.autoIncrement;
  String? authKey;
}
