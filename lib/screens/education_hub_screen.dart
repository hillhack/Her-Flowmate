import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/neu_container.dart';

class EducationHubScreen extends StatelessWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        'title': 'Hormones 101',
        'subtitle':
            'The essential guide to Estrogen, Progesterone, and your cycle.',
        'icon': '🧬',
        'color': 'FFBA68C8',
        'content':
            'Your menstrual cycle is regulated by a complex dance of hormones. Estrogen peaks right before ovulation, giving you a boost in energy and confidence. After ovulation, Progesterone takes over, which can make you feel more relaxed or sometimes sluggish as your body prepares for a potential pregnancy.\\n\\nUnderstanding this cycle allows you to predict your moods and energy levels, giving yourself grace when you need rest.',
      },
      {
        'title': 'Cycle Syncing Workouts',
        'subtitle':
            'How to align your exercise routine with your cycle phases.',
        'icon': '🏃‍♀️',
        'color': 'FFFF4081',
        'content':
            'Cycle syncing your workouts means adjusting the intensity of your exercise based on where you are in your menstrual cycle.\\n\\n• **Menstrual Phase:** Stick to gentle movements like walking or yin yoga.\\n• **Follicular Phase:** As energy rises, reintroduce cardio and strength training.\\n• **Ovulation:** Your energy peaks! Go for HIIT or heavy lifting.\\n• **Luteal Phase:** Transition from high energy to steady-state cardio, then back to gentle Pilates as your period approaches.',
      },
      {
        'title': 'Nutrition by Phase',
        'subtitle': 'Eat to support your hormones naturally.',
        'icon': '🥑',
        'color': 'FF4CAF50',
        'content':
            'Food is medicine for your hormones.\\n\\n• **Menstrual Phase:** Focus on iron-rich foods (spinach, red meat, lentils) to replenish blood loss. Add vitamin C to boost iron absorption.\\n• **Follicular Phase:** Incorporate fermented foods and fresh salads to metabolize rising estrogen.\\n• **Ovulation:** Eat anti-inflammatory foods like berries, almonds, and raw veggies to support the liver.\\n• **Luteal Phase:** Complex carbs (sweet potatoes, oats) and magnesium-rich foods (dark chocolate) help curb cravings and ease PMS.',
      },
      {
        'title': 'Understanding PCOS',
        'subtitle': 'Symptoms, management, and living gracefully with PCOS.',
        'icon': '🦋',
        'color': 'FF00BCD4',
        'content':
            'Polycystic Ovary Syndrome (PCOS) revolves around hormonal imbalances that can cause irregular cycles, acne, and cysts.\\n\\nManaging PCOS often involves a holistic approach including blood sugar stabilization, reducing stress to lower cortisol, and specific supplements like Inositol. Every body responds differently, so work with an endocrinologist to find the exact protocol that helps you feel your best.',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          ),
          _buildDreamyBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Static Top Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      NeuContainer(
                        padding: const EdgeInsets.all(12),
                        radius: 16,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.accentPink,
                          size: 26,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Knowledge Base',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.midnightPlum,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final a = articles[index];
                      final color = Color(int.parse(a['color']!, radix: 16));
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => _ArticleDetailScreen(
                                    title: a['title']!,
                                    content: a['content']!,
                                    icon: a['icon']!,
                                    themeColor: color,
                                  ),
                            ),
                          );
                        },
                        child: GlassContainer(
                          radius: 24,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  a['icon']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                a['title']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.midnightPlum,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                a['subtitle']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                          delay: (100 * index).ms,
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamyBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPink.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPurple.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String icon;
  final Color themeColor;

  const _ArticleDetailScreen({
    required this.title,
    required this.content,
    required this.icon,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 64)),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.midnightPlum,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      radius: 32,
                      child: Text(
                        content.replaceAll('\\n', '\n'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textDark.withValues(alpha: 0.8),
                          height: 1.8,
                        ),
                      ),
                    )
                    .animate()
                    .slideY(begin: 0.1, delay: 300.ms)
                    .fadeIn(delay: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
