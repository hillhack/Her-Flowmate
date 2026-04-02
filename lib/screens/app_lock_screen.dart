import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // If device doesn't support biometrics/PIN, just unlock (or show a fallback)
        widget.onUnlocked();
        return;
      }

      setState(() => _isAuthenticating = true);

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock Her-Flowmate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN/Pattern fallback
        ),
      );

      setState(() => _isAuthenticating = false);

      if (didAuthenticate) {
        widget.onUnlocked();
      }
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: $e');
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌸', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                Text(
                  'Her-Flowmate',
                  style: AppTheme.playfair(
                    fontSize: 32,
                    color: AppTheme.midnightPlum,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your privacy is our priority',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 64),
                if (_isAuthenticating)
                  const CircularProgressIndicator(color: AppTheme.accentPink)
                else
                  ThemedContainer(
                    type: ContainerType.neu,
                    onTap: _authenticate,
                    radius: 30,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fingerprint_rounded,
                          color: AppTheme.accentPink,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Unlock App',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
