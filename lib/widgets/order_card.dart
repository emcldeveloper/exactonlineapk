import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrderCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.shopping_basket_outlined),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(data['orderNo'] ?? "N/A"),
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
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ParagraphText(
              data['status'] ?? "processing",
              color: Colors.green[800],
            ),
          ),
        ),
      ],
    );
  }
}
