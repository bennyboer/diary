import 'dart:io';

import 'package:client/native.dart';
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
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dateFormat.format(widget.date)),
        centerTitle: true,
        leading: BackButton(onPressed: () => _requestClose(context)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Scrollbar(
                controller: _scrollController,
                child: TextField(
                  controller: _textEditingController,
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
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
          future: _load(),
        ),
      ),
    );
  }

  Future<String> _loadDate() {
    return Future.value('Test'); // TODO Load diary file if present
  }

  Future<void> _requestClose(BuildContext context) async {
    bool saveChanges = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildCloseDialog(ctx),
    );

    if (saveChanges) {
      _save();

      final snackBar = SnackBar(
        content: Text('Changes to ${_dateFormat.format(widget.date)} saved'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Navigator.pop(context);
  }

  _buildCloseDialog(BuildContext ctx) {
    return AlertDialog(
      title: const Text('Save changes?'),
      content: const Text('Do you want to save your changes?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _load() async {
    var diaryFile = _getDiaryFile();
    var text = await api.load(filePath: diaryFile, password: "password"); // TODO Let the user enter the password

    _textEditingController.text = text;
  }

  Future<void> _save() async {
    var text = _getText();
    var diaryFile = _getDiaryFile();

    api.save(filePath: diaryFile, password: "password", data: text); // TODO Let the user enter the password
  }

  String _getDiaryFile() {
    var homeDir = _getHomeDir()!;
    var diaryDir = "$homeDir/.diary";
    var monthDir = "$diaryDir/${widget.date.year}/${widget.date.month}";

    return "$monthDir/${widget.date.day}";
  }

  String? _getHomeDir() {
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

  String _getText() {
    return _textEditingController.text;
  }
}
