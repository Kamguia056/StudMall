import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a message to a specific user
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    String? receiverName,
    String? receiverAvatar,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final String currentUserId = currentUser.uid;
    final String currentUserName = currentUser.displayName ?? 'Utilisateur';
    final String currentUserAvatar = currentUser.photoURL ?? '';
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': false,
    };

    // Construct chat room ID from the two user IDs (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Add message to the database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Update the chat room with the last message and user details
    Map<String, dynamic> roomData = {
      'users': ids,
      'participants': ids,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'userInfo': {
        currentUserId: {'name': currentUserName, 'avatar': currentUserAvatar},
      },
    };

    if (receiverName != null) {
      // We merge receiver info only if provided (it might not be provided in subsequent replies if we don't have it)
      // But ideally we should always have it or fetch it.
      // For now, let's assume if it's passed, update it.
      Map<String, dynamic> userInfo =
          roomData['userInfo'] as Map<String, dynamic>;
      userInfo[receiverId] = {
        'name': receiverName,
        'avatar': receiverAvatar ?? '',
      };
    }

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set(roomData, SetOptions(merge: true));
  }

  // Get messages for a specific chat room
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get chat rooms for the current user
  Stream<QuerySnapshot> getUserChatRooms() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: user.uid)
        .snapshots();
  }
}
