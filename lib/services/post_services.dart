import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPost(Post post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toMap());
  }

  Stream<List<Post>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    });
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final postDoc = await postRef.get();
    final post = Post.fromMap(postDoc.data()!);

    if (post.likedBy.contains(userId)) {
      print("User already liked this post");
      return;
    }

    await postRef.update({
      'likes': post.likes + 1,
      'likedBy': FieldValue.arrayUnion([userId]), // Add userId to likedBy
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final postDoc = await postRef.get();
    final post = Post.fromMap(postDoc.data()!);

    if (!post.likedBy.contains(userId)) {
      print("User has not liked this post");
      return;
    }

    await postRef.update({
      'likes': post.likes - 1,
      'likedBy': FieldValue.arrayRemove([userId]), // Remove userId from likedBy
    });
  }
}