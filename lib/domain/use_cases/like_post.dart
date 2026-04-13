import '../repositories/i_community_repository.dart';

/// Single-purpose Use Case for liking a community post.
class LikePost {
  final ICommunityRepository repository;

  LikePost(this.repository);

  Future<void> execute(String postId) async {
    return repository.likePost(postId);
  }
}
