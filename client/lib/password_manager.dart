import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordManager {
  static const storage = FlutterSecureStorage();

  static Future<void> savePassword(String password) async {
    storage.write(key: 'password', value: password);
  }

  static Future<String?> readPassword() async {
    return storage.read(key: 'password');
  }

  static Future<void> clear() async {
    await storage.deleteAll();
  }

  static Future<bool> hasPassword() async {
    return (await readPassword()) != null;
  }
}
