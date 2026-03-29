import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import '../services/google_auth_services.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';

Widget renderWebButton(
  BuildContext context, {
  VoidCallback? onSignInComplete,
  Function(String name)? onNameFetched,
}) {
  return _GoogleWebButton(
    onSignInComplete: onSignInComplete,
    onNameFetched: onNameFetched,
  );
}

class _GoogleWebButton extends StatefulWidget {
  final VoidCallback? onSignInComplete;
  final Function(String name)? onNameFetched;

  const _GoogleWebButton({this.onSignInComplete, this.onNameFetched});

  @override
  State<_GoogleWebButton> createState() => _GoogleWebButtonState();
}

class _GoogleWebButtonState extends State<_GoogleWebButton> {
  @override
  void initState() {
    super.initState();
    _initButton();
  }

  void _initButton() {
    // Use the unified GoogleSignIn instance to listen for state changes
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    googleSignIn.authenticationEvents.listen((event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final account = event.user;
        final auth = account.authentication;
        final idToken = auth.idToken;

        if (idToken != null) {
          final backendData = await GoogleAuthService.authenticateWithBackend(
            idToken,
          );
          if (backendData != null) {
            final name = backendData['name'] ?? backendData['given_name'] ?? '';

            if (mounted) {
              final storage = context.read<StorageService>();
              await storage.completeLogin(true, name);

              if (widget.onSignInComplete != null) widget.onSignInComplete!();
              if (widget.onNameFetched != null) widget.onNameFetched!(name);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInPlugin plugin =
        GoogleSignInPlatform.instance as GoogleSignInPlugin;

    // This returns the actual GSI button widget (a PlatformView wrapper)
    return SizedBox(
      width: 300,
      height: 50,
      child: plugin.renderButton(
        configuration: GSIButtonConfiguration(
          theme: GSIButtonTheme.filledBlue,
          size: GSIButtonSize.large,
          shape: GSIButtonShape.rectangular,
        ),
      ),
    );
  }
}
