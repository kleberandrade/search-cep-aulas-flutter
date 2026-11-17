import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final names = <String>[];
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^android-[a-z-]+$').hasMatch(name) || bytes.length < 8) {
        return false;
      }
      const png = [137, 80, 78, 71, 13, 10, 26, 10];
      for (var i = 0; i < png.length; i++) {
        if (bytes[i] != png[i]) return false;
      }
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      names.add(file.path);
      return true;
    },
    responseDataCallback: (data) async {
      final version = RegExp(
        r'^version: (.+)$',
        multiLine: true,
      ).firstMatch(await File('pubspec.yaml').readAsString())?.group(1);
      final report = <String, dynamic>{...?data}..remove('screenshots');
      report['appVersion'] = version;
      report['captureSource'] =
          'integration_test: actual Android device surface';
      report['files'] = names;
      final file = File('build/android-live-result.json');
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report),
      );
    },
    writeResponseOnFailure: true,
  );
}
