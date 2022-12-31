import 'package:client/native.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String result = "{Click button}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('2 + 2 = $result'),
            ElevatedButton(
                onPressed: () => _calc(), child: const Text("Calculate"))
          ],
        ),
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
