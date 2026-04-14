import 'package:flutter/foundation.dart';
import '../domain/entities/community_post.dart';
import '../domain/use_cases/get_community_feed.dart';
import '../domain/use_cases/like_post.dart';
import '../domain/use_cases/create_community_post.dart';

/// Presentation Layer: State provider for the Community feature.
/// It only depends on Use Cases, not on raw repositories or data sources.
class CommunityProvider extends ChangeNotifier {
  final GetCommunityFeed getFeedUseCase;
  final LikePost likePostUseCase;
  final CreateCommunityPost createPostUseCase;

  CommunityProvider({
    required this.getFeedUseCase,
    required this.likePostUseCase,
    required this.createPostUseCase,
  });

  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await getFeedUseCase.execute();
    } catch (e) {
      _error = 'Failed to load community feed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId) async {
    // Optimistic Update
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final oldPost = _posts[index];
      _posts[index] = CommunityPost(
        id: oldPost.id,
        userName: oldPost.userName,
        content: oldPost.content,
        category: oldPost.category,
        createdAt: oldPost.createdAt,
        likes: oldPost.likes + 1,
      );
      notifyListeners();

      try {
        await likePostUseCase.execute(postId);
      } catch (e) {
        // Rollback on failure
        _posts[index] = oldPost;
        _error = 'Failed to like post: $e';
        notifyListeners();
      }
    }
  }

  Future<void> createPost({
    required String content,
    required String category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await createPostUseCase.execute(content: content, category: category);
      await loadFeed(); // Refresh feed after successful creation
    } catch (e) {
      _error = 'Failed to create post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
