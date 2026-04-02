import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/prediction_service.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/app_lock_screen.dart';
import 'services/google_auth_services.dart';
import 'providers/community_provider.dart';
import 'domain/use_cases/get_community_feed.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'data/repositories/mock_community_repository.dart';

/// Application entry point.
///
/// Sentry integration has been removed until a valid DSN is configured.
/// To re-enable it, add `sentry_flutter` back to pubspec.yaml and wrap
/// the `runApp()` call with `SentryFlutter.init()`.
Future<void> main() async {
  // ── Global Error Handling ────────────────────────────────────────────────
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
    // TODO: Integrate Sentry or another crash reporter with a real DSN
  };

  // Catch errors that happen during building/rendering
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialAppearanceErrorScreen(details: details);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Get device timezone
  if (!kIsWeb) {
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Could not get local timezone, defaulting to UTC: $e');
    }
  } else {
    // Web: Default to UTC or browser timezone (handled by tz by default mostly)
    debugPrint('Web: Timezone initialization simplified.');
  }

  // ── Launch the bootstrap sequence ────────────────────────────────────────
  runApp(const BootstrapScreen());

  // Set global system overlay style for a premium, edge-to-edge look
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

/// A robust startup screen that handles initialization of services.
/// This prevents "Blank Page" issues by always rendering a UI.
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
      debugPrint('Bootstrap: Initializing services...');
      final startTime = DateTime.now();

      setState(() {
        _error = null;
        _initialized = false;
      });

      // 1. Initialize core storage (opens Hive boxes) - THIS IS CRITICAL
      final storageService = StorageService.instance;
      await storageService.init();

      // 2. Initialize remaining services in parallel - NON-BLOCKING
      // We don't await them strictly if they are not needed for the very first frame
      // GoogleAuthService is used in Login, Notification in daily work.
      // But we still want them ready.
      unawaited(GoogleAuthService.init());
      unawaited(NotificationService().init());

      // 3. Ensure splash is visible for a short time to avoid flicker
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 600) {
        await Future.delayed(
          Duration(milliseconds: 600 - elapsed.inMilliseconds),
        );
      }

      if (mounted) {
        setState(() {
          _initialized = true;
        });

        // 4. Schedule reminders only after BOTH services are ready
        NotificationService().scheduleDailyCheckinReminder();
      }
    } catch (e) {
      debugPrint('FATAL ERROR DURING STARTUP: $e');
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
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.accentPink,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Startup Error',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We encountered an issue while starting HerFlowmate. This can happen if browser storage is blocked.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _initServices,
                    child: const Text('Retry Startup'),
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

    // Success: Wrap the app in providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: StorageService.instance,
        ), // Already singleton-like via init
        ProxyProvider<StorageService, PredictionService>(
          update: (context, storage, previous) => PredictionService(storage),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bug_report_rounded,
                  color: AppTheme.accentPink,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A rendering error occurred. Tapping below might fix it by resetting temporary state.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Force refresh/restart of the app state if possible
                    main();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HerFlowmateApp extends StatelessWidget {
  const HerFlowmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    return MaterialApp(
      title: 'HerFlowmate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppLockWrapper(),
    );
  }
}

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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    if (!storage.hasCompletedLogin) {
      return const WelcomeScreen();
    }

    if (!storage.hasCompletedOnboarding) {
      // Prefill name if we got it from Google during login
      final prefillName = storage.userName != 'Guest' ? storage.userName : '';
      return OnboardingScreen(prefillName: prefillName);
    }

    return const MainNavigationScreen();
  }
}
