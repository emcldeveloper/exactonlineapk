import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrderCard({Key? key, required this.data}) : super(key: key);

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
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 28,
                  color: mutedTextColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText("Order ${data['orderNo']}" ?? "N/A",
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
            child: ParagraphText(
              data['status'] ?? "processing",
              color: data['status'] == 'Completed'
                  ? Colors.green[800]
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
