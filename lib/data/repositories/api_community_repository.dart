import 'dart:convert';
import '../../domain/entities/community_post.dart';
import '../../domain/repositories/i_community_repository.dart';
import '../../services/api_service.dart';

/// Implementation of ICommunityRepository that connects to the real backend.
class ApiCommunityRepository implements ICommunityRepository {
  @override
  Future<List<CommunityPost>> getFeedPosts() async {
    final response = await ApiService.get('/community/posts');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CommunityPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load community feed: ${response.statusCode}');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    final response = await ApiService.post('/community/posts/$postId/like', {});
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to like post: ${response.statusCode}');
    }
  }

  @override
  Future<void> createPost({required String content, required String category}) async {
    final response = await ApiService.post('/community/posts', {
      'content': content,
      'category': category,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }
}
