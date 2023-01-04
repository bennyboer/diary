import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../native.dart';
import '../storage.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String result = "{Click button}";

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  Set<DateTime> availableEntries = LinkedHashSet(
    equals: isSameDay,
    hashCode: _getHashCode,
  );

  static int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    _firstDay = DateTime(now.year - 10, now.month, 1);
    _lastDay = DateTime(now.year + 10, now.month, 1);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadEntries(_focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: buildCalendar(),
            ),
          ],
        ),
      ),
    );
  }

  TableCalendar<dynamic> buildCalendar() {
    return TableCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        _openEditor(selectedDay);

        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      shouldFillViewport: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.black12,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: Colors.black),
        cellMargin: EdgeInsets.all(20),
      ),
      onPageChanged: (date) => _loadEntries(date),
      eventLoader: (date) => _getEntries(date),
    );
  }

  Future<void> _loadEntries(DateTime date) async {
    var diaryMonthFolderPath =
        DiaryStorage.getDiaryMonthFolder(date.year, date.month);
    var dates = await api.list(folder: diaryMonthFolderPath);

    availableEntries.clear();
    availableEntries
        .addAll(dates.map((e) => DateTime(date.year, date.month, e)));

    setState(() {
      _focusedDay = date;
    });
  }

  List<String> _getEntries(DateTime date) {
    bool isAvailable = availableEntries.contains(date);
    if (isAvailable) {
      return ["Entry"];
    }

    return [];
  }

  Future<void> _openEditor(DateTime selectedDay) async {
    await Navigator.pushNamed(context, '/editor', arguments: selectedDay);

    _loadEntries(_focusedDay);
  }
}
