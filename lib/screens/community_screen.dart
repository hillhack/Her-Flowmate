import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/community_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/shared_app_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const SharedAppBar(title: 'Community Space'),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: Consumer<CommunityProvider>(
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
              edgeOffset: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  24,
                  kToolbarHeight + MediaQuery.of(context).padding.top + 32,
                  24,
                  MediaQuery.of(context).padding.bottom + 100,
                ),
                itemCount: provider.posts.length,
                itemBuilder: (context, index) {
                  final post = provider.posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ThemedContainer(
                      type: ContainerType.neu,
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
                                        color: context.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${post.category} • ${DateFormat('h:mm a').format(post.createdAt)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: context.secondaryText,
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
                              color: context.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<CommunityProvider>().likePost(
                                    post.id,
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_rounded,
                                      size: 20,
                                      color: AppTheme.accentPink,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${post.likes}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 20,
                                color: context.secondaryText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reply',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: context.secondaryText,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: AppTheme.accentPink,
        label: Text(
          'Share Thoughts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.edit_note_rounded),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final contentController = TextEditingController();
    String selectedCategory = 'Self-Care';
    final categories = ['Self-Care', 'Cycle Support', 'Wellness', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Share with the community',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          dropdownColor: context.surface,
                          style: GoogleFonts.inter(color: context.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: context.onSurface.withValues(alpha: 0.6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items:
                              categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c, style: TextStyle(color: context.onSurface)),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => selectedCategory = val!),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: contentController,
                          maxLines: 4,
                          style: TextStyle(color: context.onSurface),
                          decoration: InputDecoration(
                            hintText: "What's on your mind? 🌸",
                            hintStyle: TextStyle(color: context.onSurface.withValues(alpha: 0.4)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (contentController.text.trim().isEmpty) return;

                            final provider = context.read<CommunityProvider>();
                            Navigator.pop(ctx);

                            await provider.createPost(
                              content: contentController.text.trim(),
                              category: selectedCategory,
                            );

                            if (ctx.mounted && provider.error != null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(provider.error!)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Post to Community',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
