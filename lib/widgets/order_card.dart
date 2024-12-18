import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(CustomerOrderViewPage(orderData: data));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingBasket01,
                  color: Colors.grey,
                  size: 28.0,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText("Order ${data['orderNo']}",
                        fontWeight: FontWeight.bold, fontSize: 14.0),
                    ParagraphText(data['customer'] ?? "N/A"),
                    ParagraphText(data['time'] ?? "N/A"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
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
