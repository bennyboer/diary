import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:client/edit_command.dart';
import 'package:client/pages/calendar.dart';
import 'package:client/pages/editor.dart';
import 'package:flutter/material.dart';

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
          default:
            return MaterialPageRoute(
              builder: (context) => const CalendarPage(),
            );
        }
      },
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  bool get isDark {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      default:
        return false;
    }
  }
}
