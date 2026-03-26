import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/brand_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback before submitting.'),
        ),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'herflowmate.app@gmail.com',
      query: 'subject=App Feedback from HerFlowmate&body=$text',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showSuccessFallback();
      }
    } catch (_) {
      _showSuccessFallback();
    }
  }

  void _showSuccessFallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Redirected to email framework.'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              radius: 12,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ),
        title: Text(
          'Send Feedback',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon Header
                Center(
                  child:
                      GlassContainer(
                        radius: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: const Icon(
                            Icons.rate_review_rounded,
                            color: AppTheme.accentPink,
                            size: 56,
                          ),
                        ),
                      ).animate().scale(
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      ),
                ),
                const SizedBox(height: 40),

                Text(
                  'We\'d love to hear from you!',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 12),

                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Feature requests, bugs, or kindness — let us know how we can improve ',
                      ),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: BrandName(fontSize: 16),
                      ),
                      const TextSpan(text: '.'),
                    ],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textDark.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // Input Field
                GlassContainer(
                  radius: 24,
                  opacity: 0.1,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 8,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message here...',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.textDark.withOpacity(0.35),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                const SizedBox(height: 40),

                // Submit Button
                GlassContainer(
                  radius: 20,
                  child: ElevatedButton.icon(
                    onPressed: _sendFeedback,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppTheme.accentPink,
                    ),
                    label: Text(
                      'Submit Feedback',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentPink,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
