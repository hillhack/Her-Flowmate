import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/storage_service.dart';
import 'services/prediction_service.dart';
import 'services/notification_service.dart';
import 'services/google_auth_services.dart';

import 'providers/community_provider.dart';
import 'domain/use_cases/get_community_feed.dart';
import 'data/repositories/mock_community_repository.dart';

import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/app_lock_screen.dart';

import 'utils/app_theme.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Application entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialAppearanceErrorScreen(details: details);
  };

  /// Initialize timezone database
  tz.initializeTimeZones();

  if (!kIsWeb) {
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Could not get local timezone: $e');
    }
  }

  runApp(const BootstrapScreen());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

/// Bootstrap screen
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      debugPrint('Initializing services...');

      final storageService = StorageService.instance;
      await storageService.init();

      /// Start async services
      unawaited(GoogleAuthService.init());
      unawaited(NotificationService().init());

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _initialized = true;
        });

        NotificationService().scheduleDailyCheckinReminder();
      }
    } catch (e) {
      debugPrint('Startup error: $e');

      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.accentPink,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Startup Error",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "HerFlowmate failed to start.",
                    style: GoogleFonts.inter(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initServices,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.accentPink),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: StorageService.instance),
        ProxyProvider<StorageService, PredictionService>(
          update: (_, storage, __) => PredictionService(storage),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CommunityProvider(
                getFeedUseCase: GetCommunityFeed(MockCommunityRepository()),
              ),
        ),
      ],
      child: const HerFlowmateApp(),
    );
  }
}

/// App Error UI
class MaterialAppearanceErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const MaterialAppearanceErrorScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bug_report,
                  size: 64,
                  color: AppTheme.accentPink,
                ),
                const SizedBox(height: 20),
                Text(
                  "Something went wrong",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    main();
                  },
                  child: const Text("Restart App"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main Application
class HerFlowmateApp extends StatelessWidget {
  const HerFlowmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return MaterialApp(
      title: "HerFlowmate",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppLockWrapper(),
    );
  }
}

/// App Lock
class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    if (storage.isPinLocked && !_unlocked) {
      return AppLockScreen(
        onUnlocked: () {
          setState(() {
            _unlocked = true;
          });
        },
      );
    }

    return const AuthWrapper();
  }
}

/// Auth Flow
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    if (!storage.hasCompletedLogin) {
      return const WelcomeScreen();
    }

    if (!storage.hasCompletedOnboarding) {
      final prefillName = storage.userName != "Guest" ? storage.userName : "";

      return OnboardingScreen(prefillName: prefillName);
    }

    return const MainNavigationScreen();
  }
}
