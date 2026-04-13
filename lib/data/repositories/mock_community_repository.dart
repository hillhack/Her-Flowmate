import '../../domain/entities/community_post.dart';
import '../../domain/repositories/i_community_repository.dart';

/// Implementation of ICommunityRepository that provides static/mock data.
/// This allows us to build the UI and test logic without a real backend.
class MockCommunityRepository implements ICommunityRepository {
  @override
  Future<List<CommunityPost>> getFeedPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      CommunityPost(
        id: '1',
        userName: 'Avery',
        content:
            'I just finished my first yoga session this morning! Feeling so energized. 🧘‍♀️✨',
        category: 'Self-Care',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
      ),
      CommunityPost(
        id: '2',
        userName: 'Luna',
        content:
            'Reminder for everyone in their Luteal phase: be kind to yourself today. You deserve extra rest! 🌸',
        category: 'Cycle Support',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 45,
      ),
      CommunityPost(
        id: '3',
        userName: 'Sasha',
        content:
            'Does anyone have tips for staying hydrated during busy workdays? I\'m struggling with my water goals lately. 💧',
        category: 'Wellness',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 8,
      ),
    ];
  }

  @override
  Future<void> likePost(String postId) async {
    // Simulating API call
    return;
  }

  @override
  Future<void> createPost(
      {required String content, required String category}) async {
    // Simulating API call
    return;
  }
}
