import 'package:client/native.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

import '../edit_command.dart';
import '../main.dart';
import '../password_manager.dart';
import '../storage.dart';

class EditorPage extends StatefulWidget {
  final EditCommand cmd;

  const EditorPage({super.key, required this.cmd});

  @override
  State<StatefulWidget> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  static final DateFormat _dateFormat = DateFormat('dd. MMMM yyyy');

  String _originalText = "";
  final CodeController _codeController =
      CodeController(text: "", language: markdown);

  bool _showCode = true;
  bool _showPreview = false;

  late Future<void> _loadEntryFuture;

  @override
  void initState() {
    super.initState();

    _loadEntryFuture = _load(context);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _buildBody(context);
            } else {
              return _buildLoadingIndicator();
            }
          },
          future: _loadEntryFuture,
        ),
      ),
    );
  }

  Center _buildLoadingIndicator() =>
      const Center(child: CircularProgressIndicator());

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_dateFormat.format(widget.cmd.date)),
      centerTitle: true,
      leading: BackButton(onPressed: () => _requestClose(context)),
      actions: [
        ToggleButtons(
          isSelected: [_showCode, _showPreview],
          children: const [Icon(Icons.code), Icon(Icons.preview)],
          onPressed: (index) {
            setState(() {
              if (index == 0) {
                _showCode = !_showCode;

                if (!_showPreview && !_showCode) {
                  _showCode = true;
                }
              } else {
                _showPreview = !_showPreview;

                if (!_showPreview && !_showCode) {
                  _showPreview = true;
                }
              }
            });
          },
        )
      ],
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).textTheme.bodyText1?.color,
      elevation: 0,
    );
  }

  Future<void> _requestClose(BuildContext context) async {
    bool isUnchanged = _originalText == text;
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
      await _save(context);

      final snackBar = SnackBar(
        content:
            Text('Changes to ${_dateFormat.format(widget.cmd.date)} saved'),
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

  Future<void> _load(BuildContext context) async {
    var diaryFile = _getDiaryFile();

    var text = "";
    var shouldLoadEntry = !widget.cmd.createNewEntry;
    while (shouldLoadEntry) {
      try {
        var password = await _requestPassword(context);

        text = await api.load(
          filePath: diaryFile,
          password: password,
        );
        break;
      } catch (e) {
        if (e is bool && !e) {
          Navigator.pop(context);
          return;
        }

        await PasswordManager.clear();

        const snackBar = SnackBar(
          content: Text(
              'The diary could not be decrypted. Maybe the password is wrong?'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    _originalText = text;
    _codeController.text = text;
  }

  Future<void> _save(BuildContext context) async {
    var diaryFile = _getDiaryFile();
    var password = await _requestPassword(context);

    api.save(
      filePath: diaryFile,
      password: password,
      data: text,
    );
  }

  String _getDiaryFile() => DiaryStorage.getDiaryFilePath(
        widget.cmd.date.year,
        widget.cmd.date.month,
        widget.cmd.date.day,
      );

  String get text => _codeController.text;

  Future<String> _requestPassword(BuildContext context) async {
    if (await PasswordManager.hasPassword()) {
      return await PasswordManager.readPassword() ?? "";
    } else {
      var password = await prompt(context,
          title: const Text('Enter password'),
          obscureText: true,
          autoFocus: true,
          showPasswordIcon: true);
      if (password == null) {
        throw false;
      }

      await PasswordManager.savePassword(password);

      return password;
    }
  }

  Widget _buildBody(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showCode) Expanded(child: _buildCodeEditor(context)),
          if (_showCode && _showPreview) const VerticalDivider(),
          if (_showPreview) Expanded(child: _buildPreview(context)),
        ],
      );

  Widget _buildCodeEditor(BuildContext context) => CodeTheme(
        data: CodeThemeData(
          styles: DiaryApp.of(context).isDark(context)
              ? a11yDarkTheme
              : a11yLightTheme,
        ),
        child: CodeField(
          controller: _codeController,
          textStyle: const TextStyle(fontFamily: 'SourceCode'),
          background: Theme.of(context).scaffoldBackgroundColor,
          expands: true,
          wrap: true,
          onChanged: (text) {
            if (_showPreview) {
              setState(() {});
            }
          },
        ),
      );

  Widget _buildPreview(BuildContext context) {
    return MarkdownWidget(
      data: text,
      padding: const EdgeInsets.all(8),
      styleConfig: StyleConfig(
        markdownTheme: DiaryApp.of(context).isDark(context)
            ? MarkdownTheme.darkTheme
            : MarkdownTheme.lightTheme,
        pConfig: PConfig(
          textStyle: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyText1?.color,
          ),
        ),
      ),
    );
  }
}
