import 'dart:collection';

import 'package:client/edit_command.dart';
import 'package:client/password_manager.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../native.dart';
import '../storage.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver, WindowListener {
  static final DateFormat _monthDateFormat = DateFormat.yMMMM();

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
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    windowManager.setPreventClose(true);

    var now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    _firstDay = DateTime(now.year - 10, now.month, 1);
    _lastDay = DateTime(now.year + 10, now.month, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onStartup());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    await PasswordManager.clear();
    await windowManager.destroy();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      PasswordManager.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: buildCalendar(context),
            ),
          ],
        ),
      ),
    );
  }

  TableCalendar<dynamic> buildCalendar(BuildContext context) {
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
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, date) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _monthDateFormat.format(date),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: SizedBox(
                child: DayNightSwitcher(
                  isDarkModeEnabled: DiaryApp.of(context).isDark(context),
                  onStateChanged: (isDark) {
                    DiaryApp.of(context)
                        .changeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
                    setState(() {});
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, "/settings");
                _loadEntries(_focusedDay);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Colors.black12,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: Colors.black),
        cellMargin: const EdgeInsets.all(20),
        markerDecoration: BoxDecoration(
          color: DiaryApp.of(context).isDark(context)
              ? Colors.greenAccent
              : Colors.teal,
          shape: BoxShape.circle,
        ),
        markerSize: 8,
      ),
      onPageChanged: (date) => _loadEntries(date),
      eventLoader: (date) => _getEntries(date),
    );
  }

  Future<void> _loadEntries(DateTime date) async {
    var diaryMonthFolderPath = await DiaryStorage.getDiaryMonthFolder(
      date.year,
      date.month,
    );
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
    var createNewEntry = !availableEntries.contains(selectedDay);
    await Navigator.pushNamed(
      context,
      '/editor',
      arguments: EditCommand(
        date: selectedDay,
        createNewEntry: createNewEntry,
      ),
    );

    _loadEntries(_focusedDay);
  }

  Future<void> _onStartup() async {
    _loadEntries(_focusedDay);

    var shouldAskForPassword =
        await PasswordManager.shouldAskForPasswordAtStartup();
    if (shouldAskForPassword) {
      await _requestPassword(context);
    }
  }

  Future<String> _requestPassword(BuildContext context) async {
    if (await PasswordManager.hasPassword()) {
      return await PasswordManager.readPassword() ?? "";
    } else {
      var password = await prompt(
        context,
        title: const Text('Enter password to access diary'),
        obscureText: true,
        autoFocus: true,
        showPasswordIcon: true,
      );
      if (password == null) {
        throw false;
      }

      await PasswordManager.savePassword(password);

      return password;
    }
  }
}
