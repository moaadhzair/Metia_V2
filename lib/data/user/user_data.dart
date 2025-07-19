import 'package:isar/isar.dart';
import 'package:metia/data/user/credentials.dart';
import 'package:path_provider/path_provider.dart';

class UserData {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([UserCredentialsSchema], directory: dir.path);
  }

  static Future<bool> deletAuthKey() async {
    await isar.writeTxn(() async {
      await isar.userCredentials.clear();
    });
    return true;
  }

  static Future<bool> saveAuthKey(String authKey) async {
    final creds = UserCredentials()..authKey = authKey;

    await isar.writeTxn(() async {
      await isar.userCredentials.clear();
      isar.userCredentials.put(creds);
    });
    return true;
  }

  static Future<String> getAuthKey() async {
    List<UserCredentials> creds = await isar.userCredentials.where().findAll();
    if (creds.isEmpty) {
      return "empty";
    } else {
      return creds.first.authKey!;
    }
  }
}
