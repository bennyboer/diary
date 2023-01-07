import 'package:client/main.dart';
import 'package:client/password_manager.dart';
import 'package:client/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<String> _diaryFolderFuture;
  late Future<bool> _hasPasswordFuture;
  late Future<bool> _rememberPasswordFuture;
  late Future<bool> _askForPasswordAtStartupFuture;

  @override
  void initState() {
    super.initState();

    _diaryFolderFuture = DiaryStorage.getDiaryFolder();
    _hasPasswordFuture = PasswordManager.hasPassword();
    _rememberPasswordFuture = PasswordManager.shouldRememberPassword();
    _askForPasswordAtStartupFuture =
        PasswordManager.shouldAskForPasswordAtStartup();
  }

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
                    future: _diaryFolderFuture,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        String? selectedDirectory =
                            await FilePicker.platform.getDirectoryPath(
                          initialDirectory: await DiaryStorage.getDiaryFolder(),
                        );

                        if (selectedDirectory != null) {
                          await DiaryStorage.setDiaryFolder(selectedDirectory);
                          setState(() {
                            _diaryFolderFuture = DiaryStorage.getDiaryFolder();
                          });
                        }
                      },
                      child: const Text("Select..."),
                    ),
                  ),
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
              Row(children: [
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Checkbox(
                        value: snapshot.data as bool,
                        onChanged: (value) async {
                          await PasswordManager.setRememberPassword(
                              value ?? false);
                          setState(() {
                            _rememberPasswordFuture =
                                PasswordManager.shouldRememberPassword();
                          });
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                  future: _rememberPasswordFuture,
                )
              ]),
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
              Row(children: [
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var data = snapshot.data as List<bool>;
                      var rememberPassword = data[0];
                      var askForPasswordAtStartup = data[1];

                      var onChanged;
                      if (rememberPassword) {
                        onChanged = (value) async {
                          await PasswordManager.setAskForPasswordAtStartup(
                              value ?? false);
                          setState(() {
                            _askForPasswordAtStartupFuture =
                                PasswordManager.shouldAskForPasswordAtStartup();
                          });
                        };
                      }

                      return Checkbox(
                        value: askForPasswordAtStartup,
                        onChanged: onChanged,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                  future: Future.wait([
                    _rememberPasswordFuture,
                    _askForPasswordAtStartupFuture
                  ]),
                ),
              ]),
            ],
          ),
          TableRow(
            children: [
              Container(),
              Row(
                children: [
                  FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        var hasPassword = snapshot.data as bool;
                        var onPressed;
                        if (hasPassword) {
                          onPressed = () async {
                            await PasswordManager.clear();
                            setState(() {
                              _hasPasswordFuture =
                                  PasswordManager.hasPassword();
                            });
                          };
                        }

                        return ElevatedButton(
                          onPressed: onPressed,
                          child: const Text("Forget password"),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                    future: _hasPasswordFuture,
                  ),
                ],
              )
            ],
          ),
        ],
      );

  Widget _buildThemeSwitcher(BuildContext context) {
    var themeMode = DiaryApp.of(context).themeMode;

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
        setState(() {});
      },
      children: const [
        Text("System"),
        Text("Light"),
        Text("Dark"),
      ],
    );
  }
}
