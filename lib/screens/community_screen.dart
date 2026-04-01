import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/community_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch feed on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        title: Text('Community Space', style: AppTheme.playfair(fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentPink),
            );
          }

          if (provider.error != null && provider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppTheme.accentPink,
                  ),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadFeed,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadFeed,
            color: AppTheme.accentPink,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: NeuContainer(
                    radius: 28,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.accentPink.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                post.userName[0],
                                style: const TextStyle(
                                  color: AppTheme.accentPink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${post.category} • ${DateFormat('h:mm a').format(post.createdAt)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.content,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border_rounded,
                              size: 20,
                              color: AppTheme.accentPink,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likes}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reply',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
