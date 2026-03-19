import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';

class PredictionDetailsScreen extends StatelessWidget {
  const PredictionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final nextDate = pred.nextPeriodDate;
    final avgLen = pred.averageCycleLength;
    final daysToNext = pred.daysUntilNextPeriod;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: AppTheme.neuDecoration(radius: 12, color: AppTheme.frameColor),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Prediction Details',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Highlight Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.neuDecoration(radius: 40, color: AppTheme.frameColor),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPink.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_graph_rounded, color: AppTheme.accentPink, size: 48),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        nextDate != null ? DateFormat('EEEE, MMM d').format(nextDate) : 'No Data',
                        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        daysToNext >= 0 ? 'Predicted start in $daysToNext days' : 'Tracking your next cycle',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 16, color: AppTheme.accentPink, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Calculation breakdown
                _buildSectionTitle('How we calculate this?'),
                const SizedBox(height: 16),
                _buildInfoRow('Average Cycle', '$avgLen days', Icons.loop_rounded),
                _buildInfoRow('Last Period', nextDate != null ? DateFormat('MMM d').format(nextDate.subtract(Duration(days: avgLen))) : 'None', Icons.history_rounded),
                
                const SizedBox(height: 32),

                // Transparency note
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.neuInnerDecoration(radius: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.accentPink, size: 20),
                          const SizedBox(width: 10),
                          Text('Privacy & Accuracy', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This prediction is based on your historical cycle data stored locally on your device. Cycle lengths can naturally vary due to stress, diet, or other lifestyle factors. We use a simple average of your last cycles to give you an estimate.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark.withOpacity(0.6), height: 1.5),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textDark.withOpacity(0.4), size: 22),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.accentPink, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }
}
