import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toMap());
  }

  Future<UserProfile?> getProfile(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final result = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .get();
    return result.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
  }
}