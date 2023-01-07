import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:client/edit_command.dart';
import 'package:client/pages/calendar.dart';
import 'package:client/pages/editor.dart';
import 'package:client/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DiaryApp());

  doWhenWindowReady(() {
    const initialSize = Size(900, 700);

    appWindow.title = "Diary";
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class DiaryApp extends StatefulWidget {
  const DiaryApp({super.key});

  @override
  State<StatefulWidget> createState() => DiaryAppState();

  static DiaryAppState of(BuildContext context) =>
      context.findAncestorStateOfType<DiaryAppState>()!;
}

class DiaryAppState extends State<DiaryApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThemeMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/editor":
            return MaterialPageRoute(
              builder: (context) =>
                  EditorPage(cmd: settings.arguments as EditCommand),
            );
          case "/settings":
            return MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const CalendarPage(),
            );
        }
      },
    );
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString("theme");

    setState(() {
      if (themeModeStr == null) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.values.firstWhere((e) => e.name == themeModeStr);
      }
    });
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", themeMode.name);

    setState(() {
      _themeMode = themeMode;
    });
  }

  bool isDark(BuildContext ctx) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(ctx) == Brightness.dark;
      default:
        return false;
    }
  }

  get themeMode => _themeMode;
}
