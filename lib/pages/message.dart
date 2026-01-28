import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:studmall2/services/chat_service.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messagerie Pro',
      theme: ThemeData(
        primaryColor: Color(0xFF007AFF),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        fontFamily: 'SF Pro Text',
      ),
      home: ConversationsPage(),
    );
  }
}

// MODÈLES
class User {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final String status;
  final String lastSeen;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.status,
    required this.lastSeen,
  });
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.type = MessageType.text,
  });
}

class Conversation {
  final String id;
  final User user;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;

  Conversation({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
    this.isPinned = false,
  });
}

enum MessageType { text, image, video, audio, file }

// PAGE PRINCIPALE - LISTE DES CONVERSATIONS
class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ChatService _chatService = ChatService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  String _searchQuery = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Filtres
          _buildFilterChips(),

          // Liste des conversations
          Expanded(child: _buildConversationsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startNewConversation(context);
        },
        backgroundColor: Color.fromARGB(255, 69, 1, 255),
        child: Icon(Icons.message, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 55, 2, 245),
      title: _showSearch
          ? TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : Text(
              'Messages',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search,
            color: Color.fromARGB(255, 251, 251, 255),
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(color: Colors.grey[200], height: 1),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'Non lus', 'Épinglés', 'Groupes', 'Archivés'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = filter == 'Tous';
            return Container(
              margin: EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {},
                backgroundColor: Colors.grey[100],
                selectedColor: Color.fromARGB(255, 25, 0, 255),
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final currentUser = _auth.currentUser;

        if (docs.isEmpty) {
          return const Center(child: Text('Aucune conversation'));
        }

        List<Conversation> conversations = [];

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final participants = List<String>.from(data['participants'] ?? []);

          // Find other user ID
          String otherUserId = '';
          for (var id in participants) {
            if (id != currentUser?.uid) {
              otherUserId = id;
              break;
            }
          }

          if (otherUserId.isEmpty) continue;

          // Get user info from map
          final userInfoMap = data['userInfo'] as Map<String, dynamic>? ?? {};
          final otherUserInfo =
              userInfoMap[otherUserId] as Map<String, dynamic>? ?? {};

          final name = otherUserInfo['name'] ?? 'Utilisateur';
          final avatar = otherUserInfo['avatar'] ?? '';

          conversations.add(
            Conversation(
              id: doc.id,
              user: User(
                id: otherUserId,
                name: name,
                avatar: avatar,
                isOnline: false, // Not implemented yet
                status: '',
                lastSeen: '',
              ),
              lastMessage: Message(
                id: 'last',
                senderId: '', // Not needed for list
                content: data['lastMessage'] ?? '',
                timestamp:
                    (data['lastMessageTime'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                isRead: true,
              ),
              unreadCount: 0,
            ),
          );
        }

        // Sort by last message time descending
        conversations.sort(
          (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
        );

        // Filter based on search
        if (_searchQuery.isNotEmpty) {
          conversations = conversations.where((conv) {
            return conv.user.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                conv.lastMessage.content.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            return ConversationTile(conversation: conversations[index]);
          },
        );
      },
    );
  }

  void _startNewConversation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nouveau message',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un contact...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildContactItem(
                      name: 'Nouveau groupe',
                      subtitle: 'Créer un groupe de discussion',
                      icon: Icons.group_add,
                      color: Colors.blue,
                    ),
                    _buildContactItem(
                      name: 'Nouveau canal',
                      subtitle: 'Créer un canal public',
                      icon: Icons.campaign,
                      color: Colors.green,
                    ),
                    Divider(height: 30),

                    /*
                    // Removed hardcoded new conversation logic for brevity or update later
                    ...conversations.map(
                      (conv) => _buildContactItem(
                        name: conv.user.name,
                        subtitle: conv.user.status,
                        avatar: conv.user.avatar,
                        isOnline: conv.user.isOnline,
                      ),
                    ),
                    */
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem({
    required String name,
    String? subtitle,
    String? avatar,
    IconData? icon,
    Color? color,
    bool isOnline = false,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        // Naviguer vers la conversation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              user: User(
                id: 'new',
                name: name,
                avatar: avatar ?? '',
                isOnline: isOnline,
                status: subtitle ?? '',
                lastSeen: '',
              ),
              chatId: 'new_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
      },
      leading: avatar != null
          ? Stack(
              children: [
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar)),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            )
          : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color?.withOpacity(0.1) ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color ?? Colors.grey),
            ),
      title: Text(
        name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          : null,
    );
  }
}

// TILE DE CONVERSATION
class ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const ConversationTile({Key? key, required this.conversation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return ChatDetailPage(
                    user: conversation.user,
                    chatId: conversation.id,
                  );
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar avec badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(conversation.user.avatar),
                    ),
                    if (conversation.user.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    if (conversation.isPinned)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.push_pin,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 16),

                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessage.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: conversation.unreadCount > 0
                                    ? Colors.black
                                    : Colors.grey[600],
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return '${difference.inMinutes}min';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}j';

    return '${time.day}/${time.month}';
  }
}

// PAGE DE CHAT DÉTAILLÉE
class ChatDetailPage extends StatefulWidget {
  final User user;
  final String chatId;

  const ChatDetailPage({Key? key, required this.user, required this.chatId})
    : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _chatService.sendMessage(
        receiverId: widget.user.id,
        receiverName: widget.user.name,
        receiverAvatar: widget.user.avatar,
        message: text,
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Envoyer un fichier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.photo,
                    label: 'Photo',
                    color: Colors.green,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.videocam,
                    label: 'Vidéo',
                    color: Colors.purple,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.mic,
                    label: 'Audio',
                    color: Colors.orange,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Document',
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F9FA), Color(0xFFF0F2F5)],
                ),
              ),
              child: _buildMessagesList(),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: () {
          // Navigation vers le profil
        },
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.user.avatar.isNotEmpty
                        ? widget.user.avatar
                        : 'https://via.placeholder.com/150',
                  ),
                  radius: 20,
                ),
                if (widget.user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.user.isOnline ? 'En ligne' : widget.user.status,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
        IconButton(icon: Icon(Icons.call), onPressed: () {}),
        IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessagesList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Center(child: Text("Non connecté"));

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(currentUser.uid, widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        // Note: Docs are ordered by timestamp ascending by default in service,
        // but typically chat UI usually reverses list view or orders descending.
        // My service orders ascending (oldest first).
        // ListView can reverse content if 'reverse: true'.
        // However, standard intuitive way: item 0 is at bottom?
        // Let's keep it simple. Order ascending. Scroll to bottom.

        List<Message> messages = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Message(
            id: doc.id,
            senderId: data['senderId'],
            content: data['message'],
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            isRead: data['isRead'] ?? false,
          );
        }).toList();

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          // To ensure we start at bottom, we can inverse.
          // Or just scrollToBottom on load.
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == currentUser.uid;

            // For date display logic
            final showDate =
                index == 0 ||
                messages[index - 1].timestamp.day != message.timestamp.day;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDate)
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDate(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                MessageBubble(message: message, isMe: isMe, showTime: true),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return 'Aujourd\'hui';
    if (messageDate == yesterday) return 'Hier';

    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return '${days[messageDate.weekday - 1]} ${messageDate.day}/${messageDate.month}';
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF007AFF)),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF007AFF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

// BULLE DE MESSAGE
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTime;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? Color(0xFF007AFF) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: isMe ? Radius.circular(20) : Radius.circular(4),
                bottomRight: isMe ? Radius.circular(4) : Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (showTime)
            Padding(
              padding: EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (isMe)
                    Row(
                      children: [
                        SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isRead ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
