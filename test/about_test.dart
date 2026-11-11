import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:theme/src/about/about.dart';
import 'package:theme/src/foundation/foundation.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: UiTheme.light(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('UiUpdater', () {
    test('isNewer compares x.y.z', () {
      expect(UiUpdater.isNewer('1.0.2', '1.0.1'), isTrue);
      expect(UiUpdater.isNewer('v1.1.0', '1.0.9+12'), isTrue);
      expect(UiUpdater.isNewer('2.0', '1.9.9'), isTrue);
      expect(UiUpdater.isNewer('1.0.1', '1.0.1+5'), isFalse);
      expect(UiUpdater.isNewer('1.0.0', '1.0.1'), isFalse);
      expect(UiUpdater.isNewer('1.0.1-beta', '1.0.1'), isFalse);
    });

    test('latestApkUrl', () {
      expect(
        UiUpdater.latestApkUrl('linkdrop'),
        'https://github.com/its-ash/linkdrop/releases/latest/download/linkdrop.apk',
      );
    });
  });

  testWidgets('UiDeveloperSection shows the developer and portfolio', (tester) async {
    await _pump(tester, const UiDeveloperSection());
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('Developed by'), findsOneWidget);
    expect(find.text('Ashvini Jangid'), findsOneWidget);
    expect(find.text('itsash.github.io'), findsOneWidget);
  });

  testWidgets('UiUpdateSection without checking shows version and download row', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'com.itsash.test',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: '',
    );
    await _pump(tester, const UiUpdateSection(storeId: 'test', checkForUpdates: false));
    await tester.pumpAndSettle();
    expect(find.text('Updates'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('Get the latest version'), findsOneWidget);
  });
}
