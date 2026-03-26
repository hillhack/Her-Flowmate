import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/prediction_service.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
  };

  try {
    debugPrint('STARTING APP...');
    final storageService = StorageService();
    await storageService.init();

    final notificationService = NotificationService();
    await notificationService.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ProxyProvider<StorageService, PredictionService>(
            update: (_, storage, __) => PredictionService(storage),
          ),
        ],
        child: const HerFlowmateApp(),
      ),
    );
  } catch (e) {
    debugPrint('FATAL ERROR DURING STARTUP: $e');
  }
}

class HerFlowmateApp extends StatelessWidget {
  const HerFlowmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerFlowmate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    if (!storage.hasCompletedLogin) {
      return const WelcomeScreen();
    }

    if (!storage.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    return const MainNavigationScreen();
  }
}
