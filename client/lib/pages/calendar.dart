import 'package:client/native.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    _firstDay = DateTime(now.year - 10, now.month, 1);
    _lastDay = DateTime(now.year + 10, now.month, 1);
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
      )),
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
        Navigator.pushNamed(context, '/editor', arguments: selectedDay);

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
      ),
    );
  }

  _calc() async {
    var calcResult = await api.add(left: 2, right: 2);
    setState(() {
      result = calcResult.toString();
    });
  }
}
