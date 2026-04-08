import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSecondary ? colorScheme.primary : Colors.white,
              ),
            ),
          )
        else if (icon != null)
          Icon(
            icon,
            color: isSecondary ? colorScheme.primary : Colors.white,
            size: 24,
          ),
        if (isLoading || icon != null) const SizedBox(width: 12),
        Flexible(
          child: Text(
            isLoading ? 'Please wait...' : label,
            style: GoogleFonts.outfit(
              fontSize: AppDesignTokens.buttonSize,
              fontWeight: FontWeight.w700,
              color: isSecondary ? colorScheme.primary : Colors.white,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null && !isLoading,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (onTap == null || isLoading) ? null : () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
          child: Ink(
            height: AppDesignTokens.buttonHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignTokens.buttonHPad,
              vertical: AppDesignTokens.buttonVPad,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
              gradient: isSecondary ? null : AppTheme.brandGradient,
              color: isSecondary ? colorScheme.primary.withValues(alpha: 0.1) : null,
              border: isSecondary ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5), width: 1.5) : null,
              boxShadow: isSecondary ? null : AppDesignTokens.neuShadow(context),
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
