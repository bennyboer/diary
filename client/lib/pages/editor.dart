import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditorPage extends StatefulWidget {
  final DateTime date;

  const EditorPage({super.key, required this.date});

  @override
  State<StatefulWidget> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  static final DateFormat _dateFormat = DateFormat('dd. MMMM yyyy');

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_dateFormat.format(widget.date))),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: TextField(
            scrollController: _scrollController,
            autofocus: true,
            expands: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autocorrect: false,
            onChanged: (s) => {},
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20.0),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _loadDate() {
    return Future.value('Test'); // TODO Load diary file if present
  }
}
