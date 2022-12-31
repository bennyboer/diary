#!/bin/sh
flutter_rust_bridge_codegen --rust-input core/src/api.rs \
  --dart-output client/lib/bridge.dart \
  --dart-decl-output client/lib/bridge_definitions.dart
