import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/delight_widgets.dart';

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

    final colorScheme = Theme.of(context).colorScheme;

    // Default Mobile/Desktop Button
    return ShimmerButton(
      onTap: onTap ?? () {},
      radius: 24,
      child: ThemedContainer(
        type: ContainerType.neu,
        radius: 24,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.g_mobiledata_rounded,
                color: colorScheme.primary,
                size: 26,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Continue with Google',
                  style: AppTheme.outfit(
                    context: context,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ).copyWith(letterSpacing: 0.3),
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
