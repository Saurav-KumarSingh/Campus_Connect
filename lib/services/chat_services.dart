// chat_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message (stores sender's admission number and name).
  Future<void> sendMessage(
      String chatId,
      String senderAdmissionNo,
      String message,
      String senderName,
      ) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderAdmissionNo': senderAdmissionNo,
      'senderName': senderName,
      'message': message,
      'timestamp': DateTime.now(),
    });
  }

  // Stream messages (ordered by timestamp) with default fallback values.
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var messageData = doc.data();
        return {
          'message': messageData['message'] ?? '',
          'senderAdmissionNo': messageData['senderAdmissionNo'] ?? '',
          'senderName': messageData['senderName'] ?? 'Unknown',
          'timestamp': messageData['timestamp'] ?? DateTime.now(),
        };
      }).toList();
    });
  }

  // Given a UID, fetch the corresponding admission number from the 'users' collection.
  Future<String> getUserAdmissionNo(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['admissionNo'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Error';
    }
  }

  // Look up a user's name using their admission number.
  Future<String> getUserNameByAdmissionNo(String admissionNo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('admissionNo', isEqualTo: admissionNo)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData['name'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Error';
    }
  }
}
