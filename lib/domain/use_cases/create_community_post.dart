import '../repositories/i_community_repository.dart';

/// Single-purpose Use Case for creating a community post.
class CreateCommunityPost {
  final ICommunityRepository repository;

  CreateCommunityPost(this.repository);

  Future<void> execute({required String content, required String category}) async {
    return repository.createPost(content: content, category: category);
  }
}
