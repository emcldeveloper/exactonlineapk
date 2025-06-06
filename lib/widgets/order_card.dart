import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/utils/get_hex_color.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  bool isUser;
  OrderCard({super.key, this.isUser = true, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                ClipOval(
                  child: (!isUser
                              ? data['User']["image"]
                              : data["Shop"]["shopImage"]) !=
                          null
                      ? CachedNetworkImage(
                          imageUrl: !isUser
                              ? data['User']["image"]
                              : data["Shop"]["shopImage"],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : ClipOval(
                          child: Container(
                              height: 80,
                              width: 80,
                              color: getHexColor((!isUser
                                          ? data['User']["name"]
                                          : data["Shop"]["name"])
                                      .toString()[0]
                                      .toLowerCase())
                                  .withAlpha(100),
                              child: Center(
                                  child: HeadingText((!isUser
                                          ? data['User']["name"]
                                          : data["Shop"]["name"])
                                      .toString()
                                      .split(" ")[0][0]))),
                        ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ParagraphText(
                          "Order #${data['id'].toString().split('-').first}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0),
                      ParagraphText(!isUser
                          ? data['User']["name"]
                          : data["Shop"]["name"] ?? "N/A"),
                      ParagraphText(
                          timeago.format(DateTime.parse(data['updatedAt'])) ??
                              "N/A"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(
                  color: data['status'] == 'DELIVERED'
                      ? Colors.green.withAlpha(70)!
                      : data['status'] == 'ORDERED'
                          ? Colors.amber.withAlpha(70)
                          : Colors.grey.withAlpha(70)!),
              color: data['status'] == 'DELIVERED'
                  ? Colors.green.withAlpha(30)
                  : data['status'] == 'ORDERED'
                      ? Colors.amber.withAlpha(30)
                      : Colors.grey.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: ParagraphText(data['status'] ?? "processing",
                fontWeight: FontWeight.bold,
                color: data['status'] == 'DELIVERED'
                    ? Colors.green[700]
                    : data['status'] == 'ORDERED'
                        ? Colors.amber[700]
                        : Colors.grey[700],
                fontSize: 11.0),
          ),
        ],
      ),
    );
  }
}
