import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _minimalMode = false; // Cognitive inclusion & motion sensitivity toggle

  String _getPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return 'Menstrual';
      case CyclePhase.follicular: return 'Follicular';
      case CyclePhase.ovulation: return 'Ovulation';
      case CyclePhase.luteal: return 'Luteal';
      case CyclePhase.unknown: return 'Unknown';
    }
  }

  Color _getPhaseColor(CyclePhase phase) {
    if (_minimalMode) return Colors.grey.shade400; // Muted colors for ADHD/Minimalism
    switch (phase) {
      case CyclePhase.menstrual: return const Color(0xFFFF4B6E);
      case CyclePhase.follicular: return const Color(0xFFFF8FA3);
      case CyclePhase.ovulation: return const Color(0xFFB56576);
      case CyclePhase.luteal: return const Color(0xFFE56B6F);
      case CyclePhase.unknown: return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionService = context.watch<PredictionService>();
    final storageService = context.watch<StorageService>();
    final userName = storageService.userName;
    
    final currentPhase = predictionService.currentPhase;
    final daysUntilNext = predictionService.daysUntilNextPeriod;
    final currentDay = predictionService.currentCycleDay;
    final avgCycleLen = predictionService.averageCycleLength;
    
    final phaseName = _getPhaseName(currentPhase);
    final phaseColor = _getPhaseColor(currentPhase);
    
    final progress = avgCycleLen > 0 ? (currentDay / avgCycleLen).clamp(0.0, 1.0) : 0.0;
    
    // Animate Extension Helper to respect Reduced Motion
    Animate animateHelper(Widget child) {
      return _minimalMode ? Animate(child: child) : child.animate();
    }

    return Scaffold(
      backgroundColor: _minimalMode ? Colors.black87 : const Color(0xFFFAFAFA), // Sustainable Dark UI toggle
      body: Stack(
        children: [
          // Background (Hidden if minimal mode to save battery and reduce motion)
          if (!_minimalMode)
            Positioned(
              top: -150,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [ phaseColor.withOpacity(0.4), Colors.transparent ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(end: 1.1, duration: 6.seconds).moveY(end: 30, duration: 8.seconds),
            ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          animateHelper(
                            Text(
                              'Hi, $userName',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: _minimalMode ? Colors.white : Colors.grey.shade900,
                              ),
                            )
                          ).fadeIn(duration: 500.ms).slideX(begin: -0.1),
                          animateHelper(
                            Text(
                              'Here is your flow insight.',
                              style: TextStyle(
                                fontSize: 18,
                                color: _minimalMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ).fadeIn(delay: 200.ms).slideX(begin: -0.1),
                        ],
                      ),
                      // Toggles
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(_minimalMode ? Icons.motion_photos_paused : Icons.animation, color: _minimalMode ? Colors.white : Colors.pink),
                            tooltip: 'Minimal Mode (Reduce Motion & Colors)',
                            onPressed: () => setState(() => _minimalMode = !_minimalMode),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout_rounded, color: _minimalMode ? Colors.white : Colors.pink),
                            onPressed: () async => await context.read<StorageService>().logout(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Main Dial
                  Center(
                    child: currentPhase != CyclePhase.unknown ? Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_minimalMode)
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [ BoxShadow(color: phaseColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 10) ],
                            ),
                          ),
                        SizedBox(
                          width: _minimalMode ? 200 : 280,
                          height: _minimalMode ? 200 : 280,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: _minimalMode ? 8 : 24,
                            backgroundColor: _minimalMode ? Colors.grey.shade800 : Colors.white.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        
                        Container(
                          width: _minimalMode ? 180 : 232,
                          height: _minimalMode ? 180 : 232,
                          decoration: BoxDecoration(
                            color: _minimalMode ? Colors.transparent : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Day $currentDay',
                                style: GoogleFonts.outfit(
                                  fontSize: _minimalMode ? 36 : 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  color: _minimalMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phaseName,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: phaseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ) : Column(
                      children: [
                        const Icon(Icons.water_drop_rounded, size: 80, color: Colors.grey),
                        const SizedBox(height: 24),
                        Text('No logs yet.', style: TextStyle(fontSize: 24, color: _minimalMode ? Colors.white : Colors.grey.shade800)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Bottom Data Card (Raw Aesthetics / Imperfect design)
                  if (currentPhase != CyclePhase.unknown)
                    animateHelper(
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _minimalMode ? Colors.grey.shade900 : Colors.white,
                          // "Raw Aesthetic" -> Asymmetrical, slightly off borders instead of perfect rounding
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(40),
                          ),
                          border: Border.all(
                            color: _minimalMode ? Colors.grey.shade800 : Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: _minimalMode ? null : [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(5, 5))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next expected period',
                              style: TextStyle(
                                fontSize: 16, 
                                color: _minimalMode ? Colors.grey.shade400 : Colors.grey.shade600, 
                                fontWeight: FontWeight.bold,
                                // Sketchy underline via text decoration
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.wavy,
                                decorationColor: phaseColor.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              predictionService.nextPeriodDate != null 
                               ? '${predictionService.nextPeriodDate!.day}/${predictionService.nextPeriodDate!.month}/${predictionService.nextPeriodDate!.year}'
                               : '',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: phaseColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              daysUntilNext >= 0 
                                ? 'Time left: $daysUntilNext days'
                                : 'Late by: ${daysUntilNext.abs()} days',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: _minimalMode ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      )
                    ).slideY(begin: 0.5, curve: Curves.easeOutQuart, duration: 800.ms),
                    
                  const SizedBox(height: 120), // Padding for BottomBar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
