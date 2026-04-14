import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/storage_service.dart';
import 'services/pregnancy_service.dart';
import 'services/prediction_service.dart';
import 'services/notification_service.dart';
import 'services/google_auth_services.dart';

import 'providers/community_provider.dart';
import 'domain/use_cases/get_community_feed.dart';
import 'domain/use_cases/like_post.dart';
import 'domain/use_cases/create_community_post.dart';
import 'data/repositories/api_community_repository.dart';

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

      /// Start async house-keeping services
      try {
        unawaited(GoogleAuthService.init());
        unawaited(NotificationService().init());
        NotificationService().scheduleDailyCheckinReminder();
      } catch (e) {
        debugPrint('Non-critical service init error: $e');
      }

      // Ensure splash is visible for at least a short duration for branding
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e, stack) {
      debugPrint('CRITICAL Startup error: $e');
      debugPrint(stack.toString());

      if (mounted) {
        setState(() {
          _error = _getHumanReadableError(e);
        });
      }
    }
  }

  String _getHumanReadableError(dynamic e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('hive')) return 'Database initialization failed. Please try restarting.';
    if (errStr.contains('firebase')) return 'Cloud sync setup failed. Check your connection.';
    return 'Something went wrong during startup: $e';
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
                    Icons.error_outline_rounded,
                    size: 80,
                    color: AppTheme.accentPink,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Startup Error",
                    style: AppTheme.playfair(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTheme.outfit(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _initServices,
                      child: Text("Retry Initialization", style: AppTheme.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
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
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentPink.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        errorBuilder: (ctx, _, __) => const Icon(
                          Icons.favorite_rounded,
                          size: 60,
                          color: AppTheme.accentPink,
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: StorageService.instance),
        // Expose the PregnancyService singleton that lives inside StorageService
        // so PregnancyDashboard can watch it via context.watch<PregnancyService>().
        ChangeNotifierProvider<PregnancyService>.value(
          value: StorageService.instance.pregnancy,
        ),
        ProxyProvider<StorageService, PredictionService>(
          update: (_, storage, __) => PredictionService(storage),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final repo = ApiCommunityRepository();
            return CommunityProvider(
              getFeedUseCase: GetCommunityFeed(repo),
              likePostUseCase: LikePost(repo),
              createPostUseCase: CreateCommunityPost(repo),
            );
          },
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

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final storage = StorageService.instance;
      if (storage.isPinLocked) {
        setState(() {
          _unlocked = false;
        });
      }
    }
  }

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
