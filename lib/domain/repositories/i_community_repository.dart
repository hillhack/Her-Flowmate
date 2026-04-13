import '../entities/community_post.dart';

/// Abstract interface for Community data access.
/// This lives in the Domain layer so that business logic can depend on it
/// without knowing about Hive, SQLite, or Firebase.
abstract class ICommunityRepository {
  Future<List<CommunityPost>> getFeedPosts();
  Future<void> likePost(String postId);
  Future<void> createPost({required String content, required String category});
}
