import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget userChatCard(Map<String, dynamic> chat) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        chat["Shop"]?["shopImage"] != null
            ? Container(
                height: 30,
                width: 30,
                color: Colors.grey[200],
                child: CachedNetworkImage(imageUrl: chat["Shop"]["shopImage"]))
            : ClipOval(
                child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey[200],
                    child: Center(
                        child: HeadingText(
                            "${chat["Shop"]["name"].toString().split(" ")[0][0]}"))),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagraphText(
                chat["Shop"]["name"] ?? 'Unknown',
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              spacer(),
              ParagraphText(
                chat["lastMessage"] ?? "Write new message",
                color: mutedTextColor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
