class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final int likes;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.likes = 0,
    this.likedBy = const [], // Initialize likedBy as an empty list
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'likes': likes,
      'likedBy': likedBy, // Include likedBy in the map
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      timestamp: map['timestamp'].toDate(),
      imageUrl: map['imageUrl'],
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []), // Convert to List<String>
    );
  }
}