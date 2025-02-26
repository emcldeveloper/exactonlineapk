import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Badge(
                  child: const Icon(Bootstrap.cart),
                  backgroundColor: primary,
                  label: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 7,
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
                          "Order ${data['id'].toString().split('-').first}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0),
                      ParagraphText(data['User']["name"] ?? "N/A"),
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
            width: 90,
            height: 35,
            decoration: BoxDecoration(
              color: data['status'] == 'Completed'
                  ? Colors.green[100]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: ParagraphText(data['status'] ?? "processing",
                color: data['status'] == 'Completed'
                    ? Colors.green[800]
                    : Colors.black,
                fontSize: 11.0),
          ),
        ],
      ),
    );
  }
}
