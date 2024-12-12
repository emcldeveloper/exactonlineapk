import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget chatCard(Map<String, dynamic> message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(
            message['avatar'] ?? 'assets/images/default_avatar.png',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(const ConversationPage());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParagraphText(
                  message['name'] ?? 'Unknown',
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
                spacer(),
                ParagraphText(
                  message['message'] ?? '',
                  color: mutedTextColor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
