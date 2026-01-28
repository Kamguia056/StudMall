import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> with SingleTickerProviderStateMixin {
  late AnimationController animCtrl;
  late Animation<Offset> slideAnim;

  final List<Map<String, dynamic>> conversations = [
    {
      "name": "Jean Martin",
      "lastMsg": "D’accord, je vous envoie ça",
      "time": "14:32",
      "avatar": "https://i.pravatar.cc/150?img=3",
      "unread": 2,
      "online": true,
    },
    {
      "name": "Boutique Admin",
      "lastMsg": "Votre commande est prête",
      "time": "12:10",
      "avatar": "https://i.pravatar.cc/150?img=5",
      "unread": 0,
      "online": false,
    },
    {
      "name": "Sarah T.",
      "lastMsg": "Merci beaucoup !",
      "time": "Hier",
      "avatar": "https://i.pravatar.cc/150?img=8",
      "unread": 4,
      "online": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    slideAnim = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOut));
    animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_comment_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Rechercher...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: SlideTransition(
              position: slideAnim,
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (_, i) {
                  final conv = conversations[i];
                  return _buildConversationTile(conv);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv) {
    return GestureDetector(
      onTap: () {
        // TODO : Ouvrir la page Chat
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            // 🟢 Avatar + statut
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(conv["avatar"]),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: conv["online"] ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // 🎯 Infos du contact
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv["lastMsg"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 🕒 Heure + badge
            Column(
              children: [
                Text(
                  conv["time"],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                if (conv["unread"] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${conv["unread"]}",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
