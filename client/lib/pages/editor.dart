import 'package:client/native.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../storage.dart';

class EditorPage extends StatefulWidget {
  final DateTime date;

  const EditorPage({super.key, required this.date});

  @override
  State<StatefulWidget> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  static final DateFormat _dateFormat = DateFormat('dd. MMMM yyyy');

  String _originalText = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _buildTextfield();
            } else {
              return _buildLoadingIndicator();
            }
          },
          future: _load(),
        ),
      ),
    );
  }

  Center _buildLoadingIndicator() =>
      const Center(child: CircularProgressIndicator());

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_dateFormat.format(widget.date)),
      centerTitle: true,
      leading: BackButton(onPressed: () => _requestClose(context)),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  Scrollbar _buildTextfield() => Scrollbar(
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

  Future<void> _requestClose(BuildContext context) async {
    bool isUnchanged = _originalText == _textEditingController.text;
    if (isUnchanged) {
      Navigator.pop(context);
      return;
    }

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
    var text = await api.load(
      filePath: diaryFile,
      password: "password",
    ); // TODO Let the user enter the password

    _originalText = text;
    _textEditingController.text = text;
  }

  Future<void> _save() async {
    var diaryFile = _getDiaryFile();

    api.save(
      filePath: diaryFile,
      password: "password",
      data: text,
    ); // TODO Let the user enter the password
  }

  String _getDiaryFile() => DiaryStorage.getDiaryFilePath(
        widget.date.year,
        widget.date.month,
        widget.date.day,
      );

  String get text => _textEditingController.text;
}
