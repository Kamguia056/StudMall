import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String avatar;
  final bool online;

  const ChatPage({
    super.key,
    required this.name,
    required this.avatar,
    required this.online,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController msgController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();

  List<Map<String, dynamic>> messages = [
    {
      "text": "Bonjour, comment puis-je vous aider ?",
      "me": false,
      "image": null,
      "time": "09:20",
    },
    {
      "text": "Je veux acheter un produit.",
      "me": true,
      "image": null,
      "time": "09:22",
    },
  ];

  bool isTyping = false;

  void sendMessage({String? text, File? image}) {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    setState(() {
      messages.add({
        "text": text,
        "me": true,
        "image": image,
        "time": TimeOfDay.now().format(context),
      });
    });

    msgController.clear();
    isTyping = false;

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      sendMessage(image: File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.avatar)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  widget.online ? "En ligne" : "Hors ligne",
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.online ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemBuilder: (_, i) {
                final msg = messages[i];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 6),
              child: Row(
                children: const [
                  SizedBox(
                    height: 10,
                    width: 30,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "En train d'écrire...",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(msg) {
    final isMe = msg["me"] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg["image"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(msg["image"], height: 180),
              ),
            if (msg["text"] != null && msg["text"] != "")
              Text(
                msg["text"],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              msg["time"],
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo, color: Colors.deepPurple),
            onPressed: pickImage,
          ),
          Expanded(
            child: TextField(
              controller: msgController,
              onChanged: (v) => setState(() => isTyping = v.trim().isNotEmpty),
              decoration: const InputDecoration(
                hintText: "Votre message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () => sendMessage(text: msgController.text),
          ),
        ],
      ),
    );
  }
}
