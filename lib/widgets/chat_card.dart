import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget ChatCard(Map<dynamic, dynamic> message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar with image
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(
            message['avatar'] ??
                'assets/images/default_avatar.png', // Default image
          ),
        ),
        const SizedBox(width: 12),
        // Name and message column
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(ConversationPage());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParagraphText(
                  message['name'] ?? 'Unknown',
                  fontWeight: FontWeight.bold,
                ),
                spacer(),
                ParagraphText(
                  message['message'] ?? '',
                  color: mutedTextColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Arrow icon
        GestureDetector(
          onTap: () {
            Get.to(() => ConversationPage(), arguments: message);
          },
          child: Icon(
            Icons.arrow_forward_ios_outlined,
            color: mutedTextColor,
            size: 16,
          ),
        ),
      ],
    ),
  );
}
