import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BrandName extends StatelessWidget {
  final double fontSize;
  final bool shouldAnimate;

  const BrandName({super.key, this.fontSize = 28, this.shouldAnimate = true});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.brandGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        'HerFlowmate',
        style: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white, // This will be masked by the gradient
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showName;

  const BrandLogo({super.key, this.size = 80, this.showName = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/app_icon.png', width: size, height: size),
        if (showName) ...[
          const SizedBox(height: 12),
          const BrandName(fontSize: 32),
        ],
      ],
    );
  }
}
