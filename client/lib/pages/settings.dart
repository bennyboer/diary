import 'package:client/main.dart';
import 'package:client/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: _buildBody(context),
        ),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyText1?.color,
        elevation: 0,
      );

  Widget _buildBody(BuildContext context) => Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Text(
                  "Theme",
                  textAlign: TextAlign.right,
                ),
              ),
              _buildThemeSwitcher(context),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Text(
                  "Save location",
                  textAlign: TextAlign.right,
                ),
              ),
              Row(
                children: [
                  FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(snapshot.data as String);
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                    future: DiaryStorage.getDiaryFolder(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath(
                        initialDirectory: await DiaryStorage.getDiaryFolder(),
                      );

                      if (selectedDirectory != null) {
                        await DiaryStorage.setDiaryFolder(selectedDirectory);
                        setState(() {});
                      }
                    },
                    child: const Text("Select..."),
                  )
                ],
              )
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Text(
                  "Remember password for the session when typed in once",
                  textAlign: TextAlign.right,
                ),
              ),
              Checkbox(
                value: true,
                onChanged: (value) {
                  // TODO
                },
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Text(
                  "Ask for password when opening the app",
                  textAlign: TextAlign.right,
                ),
              ),
              Checkbox(
                value: false,
                onChanged: (value) {
                  // TODO
                },
              ),
            ],
          ),
        ],
      );

  Widget _buildThemeSwitcher(BuildContext context) {
    ThemeMode themeMode = DiaryApp.of(context).themeMode;

    return ToggleButtons(
      isSelected: [
        themeMode == ThemeMode.system,
        themeMode == ThemeMode.light,
        themeMode == ThemeMode.dark,
      ],
      onPressed: (index) {
        switch (index) {
          case 0:
            DiaryApp.of(context).changeTheme(ThemeMode.system);
            break;
          case 1:
            DiaryApp.of(context).changeTheme(ThemeMode.light);
            break;
          case 2:
            DiaryApp.of(context).changeTheme(ThemeMode.dark);
            break;
        }
      },
      children: const [
        Text("System"),
        Text("Light"),
        Text("Dark"),
      ],
    );
  }
}
