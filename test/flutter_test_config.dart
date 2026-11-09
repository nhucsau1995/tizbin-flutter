import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Load the real Vazirmatn font so layout and overflow checks match the device
/// (the default test font draws every glyph as a wide square).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Vazirmatn');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(rootBundle.load('assets/fonts/Vazirmatn-$w.ttf'));
  }
  await loader.load();
  await testMain();
}
