import 'dart:io';

class DiaryStorage {
  static String getDiaryMonthFolder(int year, int month) {
    var homeDir = _getHomeDir()!;
    var diaryDir = "$homeDir/.diary";

    return "$diaryDir/$year/$month";
  }

  static String getDiaryFilePath(int year, int month, int day) {
    var monthDir = getDiaryMonthFolder(year, month);

    return "$monthDir/$day";
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
