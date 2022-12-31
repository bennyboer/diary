import 'dart:io';

import 'package:client/bridge.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

const base = 'diary_core';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = loadDylib(path);
late final api = CoreImpl(dylib);
