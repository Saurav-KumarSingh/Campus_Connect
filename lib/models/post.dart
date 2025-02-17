class Post {
  String id;
  String userId;
  String content;
  DateTime timestamp;
  String? imageUrl; // This field is now optional for storing image URL

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.imageUrl, // imageUrl is optional
  });

  // Convert Post object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
      'imageUrl': imageUrl, // Include imageUrl if available
    };
  }

  // Convert map from Firestore to Post object
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      timestamp: map['timestamp'].toDate(),
      imageUrl: map['imageUrl'], // Get imageUrl from map if available
    );
  }
}