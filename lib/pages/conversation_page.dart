import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConversationPage extends StatefulWidget {
  Map<String, dynamic> chat;
  ConversationPage(this.chat, {super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Map<String, dynamic> chatData =
      Get.arguments as Map<String, dynamic>? ?? {};
  final List<String> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  UserController userController = Get.find();
//check if is person or user
  bool isUser() {
    bool isUser = true;
    if (widget.chat["UserId"] != userController.user.value["id"]) {
      isUser = false;
    }
    return isUser;
  }

  TextEditingController messageController = TextEditingController();
  // List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        leadingWidth: 20,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
              size: 16.0,
            ),
          ),
        ),
        title: Row(
          children: [
            ClipOval(
                child: isUser()
                    ? widget.chat["Shop"]["shopImage"] != null
                        ? Container(
                            height: 30,
                            width: 30,
                            child: CachedNetworkImage(
                              imageUrl: widget.chat["Shop"]["shopImage"],
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Bootstrap.shop),
                            ),
                          )
                    : widget.chat["User"]["image"] != null
                        ? Container(
                            height: 30,
                            width: 30,
                            child: CachedNetworkImage(
                              imageUrl: widget.chat["User"]["image"],
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Bootstrap.person),
                            ),
                          )),
            const SizedBox(width: 8),
            HeadingText(isUser()
                ? widget.chat["Shop"]["name"]
                : widget.chat["User"]["name"])
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Reverse the list to start from the bottom
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length + 1, // Includes the initial message
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  // Display the initial message (only once at the top when reversed)
                  return Align(
                    alignment: Alignment.bottomLeft,
                    child: ChatBubble(
                      text: chatData['message'] ?? 'No message available.',
                      isSentByMe: false,
                    ),
                  );
                }
                // Correctly access the reversed index for the messages
                return Align(
                  alignment: Alignment.bottomRight,
                  child: ChatBubble(
                    text: messages[messages.length - 1 - index],
                    isSentByMe: true,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      hintText: "Write your message here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(13.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Transform.rotate(
                      angle: 6.3,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSent,
                        color: Colors.white,
                        size: 22.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({required this.text, required this.isSentByMe, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isSentByMe ? 12 : 0),
          bottomRight: Radius.circular(isSentByMe ? 0 : 12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
