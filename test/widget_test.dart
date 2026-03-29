import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:her_flowmate/screens/login_screen.dart';
import 'package:her_flowmate/services/prediction_service.dart';
import 'package:her_flowmate/services/storage_service.dart';
import 'package:her_flowmate/models/period_log.dart';

// Fake StorageService that circumvents Hive for headless widget testing
class FakeStorageService extends StorageService {
  List<PeriodLog> logs = [];
  bool loggedIn = false;
  String customName = '';

  @override
  Future<void> init() async {}

  @override
  List<PeriodLog> getLogs() => logs;

  @override
  bool get hasCompletedLogin => loggedIn;

  @override
  String get userName => customName;
}

void main() {
  testWidgets('LoginScreen renders and correctly accepts input smoke test', (
    WidgetTester tester,
  ) async {
    final fakeStorage = FakeStorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StorageService>.value(value: fakeStorage),
          ProxyProvider<StorageService, PredictionService>(
            update: (context, storage, previous) => PredictionService(storage),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Fast-forward to clear flutter_animate entry delays (e.g. 400ms fade-ins)
    await tester.pump(const Duration(seconds: 1));

    // Verify initial render state texts
    expect(find.text('Her '), findsOneWidget);
    expect(find.text('FlowMate'), findsOneWidget);
    expect(find.text('Privacy First'), findsOneWidget);

    // Check for the login and guest buttons
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Fast-forward time to clear flutter_animate delay timers
    await tester.pump(const Duration(seconds: 2));
  });
}
