import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rf;
import 'package:go_router/go_router.dart' as gr;
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import 'prediction_service.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/mode_settings_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/log_period_screen.dart';
import '../screens/community_screen.dart';
import '../screens/partner_sync_screen.dart';
import '../screens/about_screen.dart';
import '../screens/daily_checkin_screen.dart';
import '../screens/wellness_reminders_screen.dart';

// Provider for SharedPreferences (initialized in main)
final sharedPreferencesProvider = rf.Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main and override');
});

// Provider for StorageService
final storageServiceProvider = rf.Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize this in main and override');
});

// Provider for PredictionService
final predictionServiceProvider = rf.Provider<PredictionService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PredictionService(storage);
});

// Provider for GoRouter
final routerProvider = rf.Provider<gr.GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);

  return gr.GoRouter(
    initialLocation: '/',
    refreshListenable: storage,
    redirect: (context, state) {
      final isLoggedIn = storage.hasCompletedLogin;
      final isOnboarded = storage.hasCompletedOnboarding;

      final inAuthFlow =
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return inAuthFlow ? null : '/welcome';
      }

      if (!isOnboarded) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }

      if (inAuthFlow || state.matchedLocation == '/onboarding') {
        return '/home';
      }

      return null;
    },
    routes: [
      gr.GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      gr.GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      gr.GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      gr.GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      gr.GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      gr.GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      gr.GoRoute(
        path: '/log',
        pageBuilder:
            (context, state) => const MaterialPage(
              fullscreenDialog: true,
              child: LogPeriodScreen(),
            ),
      ),
      gr.GoRoute(
        path: '/settings',
        builder: (context, state) => const ModeSettingsScreen(),
      ),
      gr.GoRoute(
        path: '/support',
        builder: (context, state) => const FeedbackScreen(),
      ),
      gr.GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      gr.GoRoute(
        path: '/partner',
        builder: (context, state) => const PartnerSyncScreen(),
      ),
      gr.GoRoute(
        path: '/about',
        builder: (context, state) => const AboutAppScreen(),
      ),
      gr.GoRoute(
        path: '/daily-checkin',
        builder: (context, state) => const DailyCheckinScreen(),
      ),
      gr.GoRoute(
        path: '/reminders',
        builder: (context, state) => const WellnessRemindersScreen(),
      ),
    ],
  );
});
