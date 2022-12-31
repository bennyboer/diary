import 'package:client/pages/calendar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const CalendarPage(),
    );
  }
}
