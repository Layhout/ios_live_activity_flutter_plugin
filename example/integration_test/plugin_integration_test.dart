// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:live_activity_plugin/live_activity_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('find out if LiveActivity is allowed',
      (WidgetTester tester) async {
    await LiveActivityManager.init();
    final bool allowed = await LiveActivityManager.isActivitiesAllowed();

    expect(allowed.runtimeType, bool);
  });
}
