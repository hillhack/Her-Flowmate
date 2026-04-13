// Pure Domain Entity - No Hive, No JSON logic.
class CommunityPost {
  final String id;
  final String userName;
  final String content;
  final String category; // e.g. "Self-Care", "Cycle Tips"
  final DateTime createdAt;
  final int likes;

  CommunityPost({
    required this.id,
    required this.userName,
    required this.content,
    required this.category,
    required this.createdAt,
    this.likes = 0,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'] as String,
    userName: json['userName'] as String,
    content: json['content'] as String,
    category: json['category'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    likes: json['likes'] as int? ?? 0,
  );
}
