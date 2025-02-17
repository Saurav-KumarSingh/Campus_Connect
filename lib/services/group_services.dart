// group_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new group.
  Future<void> createGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).set(group.toMap());
  }

  // Fetch all groups.
  Stream<List<Group>> getGroups() {
    return _firestore.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
    });
  }

  // Search groups by name.
  Future<List<Group>> searchGroups(String query) async {
    final result = await _firestore
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .get();
    return result.docs.map((doc) => Group.fromMap(doc.data())).toList();
  }

  // Add a new member (by admission number) to the group.
  Future<void> addMemberToGroup(String groupId, String admissionNo) async {
    try {
      DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
      await groupRef.update({
        'members': FieldValue.arrayUnion([admissionNo]),
      });
    } catch (e) {
      throw Exception("Error adding member to group: $e");
    }
  }

  // Remove a member (by admission number) from the group.
  Future<void> removeMemberFromGroup(String groupId, String admissionNo) async {
    try {
      DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
      await groupRef.update({
        'members': FieldValue.arrayRemove([admissionNo]),
      });
    } catch (e) {
      throw Exception("Error removing member from group: $e");
    }
  }

  // Get group details.
  Stream<Group> getGroup(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map((doc) {
      return Group.fromMap(doc.data()!);
    });
  }
}
