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

Widget userChatCard(Map<String, dynamic> chat) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        chat["Shop"]?["shopImage"] != null
            ? ClipOval(
                child: Container(
                    height: 50,
                    width: 50,
                    color: getHexColor(
                        chat["Shop"]["name"].toString()[0].toLowerCase()),
                    child: CachedNetworkImage(
                        imageUrl: chat["Shop"]["shopImage"])),
              )
            : ClipOval(
                child: Container(
                    height: 50,
                    width: 50,
                    color: getHexColor(
                            chat["Shop"]["name"].toString()[0].toLowerCase())
                        .withAlpha(100),
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
  );
}
