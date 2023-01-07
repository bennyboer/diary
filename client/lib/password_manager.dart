import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<bool> shouldRememberPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberPassword') ?? true;
  }

  static Future<void> setRememberPassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberPassword', value);
  }

  static Future<bool> shouldAskForPasswordAtStartup() async {
    var shouldRemember = await shouldRememberPassword();
    if (!shouldRemember) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('askForPasswordAtStartup') ?? true;
  }

  static Future<void> setAskForPasswordAtStartup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('askForPasswordAtStartup', value);
  }
}
