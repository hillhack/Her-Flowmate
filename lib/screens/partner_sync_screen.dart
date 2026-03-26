import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../services/storage_service.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';

class PartnerSyncScreen extends StatefulWidget {
  const PartnerSyncScreen({super.key});

  @override
  State<PartnerSyncScreen> createState() => _PartnerSyncScreenState();
}

class _PartnerSyncScreenState extends State<PartnerSyncScreen> {
  String? _syncCode;

  void _generateCode() {
    final random = Random();
    final parts = List.generate(3, (_) => random.nextInt(900) + 100);
    setState(() {
      _syncCode = '${parts[0]}-${parts[1]}-${parts[2]}';
    });
  }

  void _copyCode() {
    if (_syncCode != null) {
      Clipboard.setData(ClipboardData(text: _syncCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync code copied to clipboard!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTheme.accentPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final pred = context.watch<PredictionService>();
    final phase = pred.currentPhase;
    final name = storage.userName.isNotEmpty
        ? storage.userName.split(' ').first
        : 'Your Partner';

    String partnerMessage = '';
    switch (phase) {
      case CyclePhase.menstrual:
        partnerMessage =
            "$name is currently on her Period. Energy levels might be low. It's a great time for extra cuddles, hot tea, and bringing her favorite snacks!";
        break;
      case CyclePhase.follicular:
        partnerMessage =
            "$name is in her Follicular Phase. She's likely feeling energetic, creative, and ready to socialize. Plan a fun date out!";
        break;
      case CyclePhase.ovulation:
        partnerMessage =
            "$name is Ovulating! She's likely feeling confident, outgoing, and radiant. A perfect time for romantic evenings.";
        break;
      case CyclePhase.luteal:
        partnerMessage =
            "$name is in her Luteal Phase. She might start feeling more inward, moody, or physically tired as her period approaches. Be extra patient and supportive!";
        break;
      default:
        partnerMessage =
            "$name hasn't logged enough data yet, but today is always a good day to show her some extra love!";
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Partner Sync',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child:
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.accentPink,
                          size: 64,
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Share Your Cycle',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'Generate a secure sync code so your partner can understand your phases and know exactly how to support you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                GlassContainer(
                  padding: const EdgeInsets.all(32),
                  radius: 32,
                  child: Column(
                    children: [
                      if (_syncCode == null) ...[
                        GestureDetector(
                          onTap: _generateCode,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFBA68C8),
                                  AppTheme.accentPink,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPink.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Generate Sync Code',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Your Sync Code',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentPink.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _syncCode!,
                            style: GoogleFonts.robotoMono(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                              letterSpacing: 4,
                            ),
                          ),
                        ).animate().scale(
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: _copyCode,
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppTheme.accentPink,
                          ),
                          label: Text(
                            'Copy Code',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentPink,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 48),

                Text(
                  'Preview: What they will see today',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.phaseColor(
                                phase.displayName,
                              ).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              color: AppTheme.phaseColor(phase.displayName),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${name}'s Phase",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  phase.displayName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.phaseColor(
                                      phase.displayName,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        child: Text(
                          partnerMessage,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
