import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';
import '../widgets/delight_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

// Conditional import for Web
import 'google_auth_button_stub.dart'
    if (dart.library.js_util) 'google_auth_button_web.dart'
    as platform_button;

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onTap;

  const GoogleAuthButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return platform_button.renderWebButton(context);
    }

    // Default Mobile/Desktop Button
    return ShimmerButton(
      onTap: onTap ?? () {},
      radius: 24,
      child: NeuContainer(
        radius: 24,
        gradient: LinearGradient(
          colors:
              AppTheme.brandGradient.colors
                  .map((c) => c.withValues(alpha: 0.1))
                  .toList(),
          begin: AppTheme.brandGradient.begin,
          end: AppTheme.brandGradient.end,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.g_mobiledata_rounded,
                color: AppTheme.accentPink,
                size: 26,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Continue with Google',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
