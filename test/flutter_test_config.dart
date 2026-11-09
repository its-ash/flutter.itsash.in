import 'dart:async';

import 'package:theme/theme.dart';

/// Runs before every test file: no network font fetching in tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  UiTypography.useGoogleFonts = false;
  await testMain();
}
