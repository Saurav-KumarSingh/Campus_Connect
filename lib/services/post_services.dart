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
}