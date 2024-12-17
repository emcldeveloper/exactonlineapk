import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/notification_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final List<Map<String, String>> _notifications = const [
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
    {
      "message":
          "Get new products from best sellers, with amazing prices and discounts",
      "time": "2 mins ago"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 16.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: HeadingText(
          "Notifications",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _notifications.map((item) {
              return Column(
                children: [
                  NotificationCard(data: item),
                  spacer1(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
