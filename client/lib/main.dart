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

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
}
