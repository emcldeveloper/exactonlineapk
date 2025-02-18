import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget shopChatCard(Map<String, dynamic> chat) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              chat["User"]?["image"] != null
                  ? ClipOval(
                      child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[200],
                          child: CachedNetworkImage(
                            imageUrl: chat["User"]?["image"],
                            fit: BoxFit.cover,
                          )),
                    )
                  : ClipOval(
                      child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[200],
                          child: Center(
                              child: HeadingText(
                                  "${chat["User"]["name"].toString().split(" ")[0][0]}"))),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText(
                      chat["User"]["name"] ?? 'Unknown',
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    spacer(),
                    ParagraphText(
                      chat["lastMessage"] ?? "",
                      color: mutedTextColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
