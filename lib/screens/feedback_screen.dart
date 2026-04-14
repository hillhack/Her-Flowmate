import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/brand_widgets.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    // Try API first
    try {
      final response = await ApiService.post('/feedback', {
        'message': text,
        'platform':
            Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Web'),
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _isLoading = false);
        _feedbackController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback sent! Thank you 💌')),
          );
          Navigator.pop(context);
        }
        return;
      }
    } catch (e) {
      debugPrint('API Feedback Error: $e');
    }

    // Fallback to mailto
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'herflowmate.app@gmail.com',
      queryParameters: {
        'subject': 'App Feedback from HerFlowmate',
        'body': text,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) Navigator.pop(context);
      } else {
        _showSuccessFallback();
      }
    } catch (_) {
      _showSuccessFallback();
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: const ThemedContainer(
              type: ContainerType.glass,
              radius: 12,
              padding: EdgeInsets.zero,
              child: Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
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
                  child: const ThemedContainer(
                    type: ContainerType.glass,
                    radius: 40,
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Icon(
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

                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Feature requests, bugs, or kindness — let us know how we can improve ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: BrandName(fontSize: 16),
                      ),
                      TextSpan(text: '.'),
                    ],
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0x992E1E3C), // Approximate textDark 0.6
                      height: 1.5,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // Input Field
                ThemedContainer(
                  type: ContainerType.glass,
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
                          color: AppTheme.textDark.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                const SizedBox(height: 40),

                // Submit Button
                ThemedContainer(
                  type: ContainerType.glass,
                  radius: 20,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendFeedback,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accentPink,
                              ),
                            )
                            : const Icon(
                              Icons.send_rounded,
                              color: AppTheme.accentPink,
                            ),
                    label: Text(
                      _isLoading ? 'Sending...' : 'Submit Feedback',
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
