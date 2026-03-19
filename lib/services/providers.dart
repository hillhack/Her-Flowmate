import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

// Provider for SharedPreferences (initialized in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main and override');
});

// Provider for StorageService
final storageServiceProvider = ChangeNotifierProvider<StorageService>((ref) {
  throw UnimplementedError('Initialize this in main and override');
});

// Provider for PredictionService
final predictionServiceProvider = Provider<PredictionService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PredictionService(storage);
});

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: storage,
    redirect: (context, state) {
      final isLoggedIn = storage.hasCompletedLogin;
      final isOnboarded = storage.hasCompletedOnboarding;
      
      final inAuthFlow = state.matchedLocation == '/welcome' || state.matchedLocation == '/login';
      
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
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/log',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: LogPeriodScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ModeSettingsScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const FeedbackScreen(),
      ),
    ],
  );
});
