import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'services/prediction_service.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

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
}

class HerFlowmateApp extends StatelessWidget {
  const HerFlowmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        return MaterialApp(
          title: 'Her-Flowmate',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pink,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(),
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          ),
          home: storage.hasCompletedLogin ? const MainNavigationScreen() : const LoginScreen(),
        );
      },
    );
  }
}
