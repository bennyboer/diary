import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class DiaryStorage {
  static Future<String> getDiaryMonthFolder(int year, int month) async {
    var diaryDir = await getDiaryFolder();

    return "$diaryDir/$year/$month";
  }

  static Future<String> getDiaryFilePath(int year, int month, int day) async {
    var monthDir = await getDiaryMonthFolder(year, month);

    return "$monthDir/$day";
  }

  static Future<String> getDiaryFolder() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('diaryDir') ?? _getDefaultDiaryFolder();
  }

  static Future<void> setDiaryFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('diaryDir', path);
  }

  static String _getDefaultDiaryFolder() {
    var homeDir = _getHomeDir()!;
    var diaryDir = "$homeDir/.diary";

    return diaryDir;
  }

  static String? _getHomeDir() {
    Map<String, String> env = Platform.environment;
    if (Platform.isMacOS) {
      return env['HOME'];
    } else if (Platform.isLinux) {
      return env['HOME'];
    } else if (Platform.isWindows) {
      return env['USERPROFILE'];
    } else if (Platform.isAndroid) {
      return "/storage/sdcard0";
    }

    throw Exception('Unsupported platform');
  }
}
