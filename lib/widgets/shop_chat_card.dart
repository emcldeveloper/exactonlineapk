import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/get_hex_color.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart';

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
                          color: getHexColor(chat["User"]["name"]
                                  .toString()[0]
                                  .toLowerCase())
                              .withAlpha(100),
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
                      chat["lastMessage"] ?? "Send a new message",
                      color: mutedTextColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    format(DateTime.parse(
                        chat["lastMessageDatetime"] ?? chat["createdAt"])),
                    style: TextStyle(fontSize: 12),
                  ),
                  if (int.parse((chat["unreadMessages"] ?? 0).toString()) > 0)
                    ClipOval(
                      child: Container(
                        width: 18,
                        height: 18,
                        color: primary,
                        child: Center(
                          child: Text(
                            (chat["unreadMessages"] ?? 0).toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}
