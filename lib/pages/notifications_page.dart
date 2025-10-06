import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/notification_controller.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/notification_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController notificationController =
      Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when page opens
    Future.delayed(Duration.zero, () {
      notificationController.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "NotificationsPage",
        screenClass: "NotificationsPage",
      );
    });
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
        title: HeadingText("Notifications"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder(
        future: notificationController.getNotifications(1, 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text("Error loading notifications"));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return noData();
          } else {
            var notifications = snapshot.data as List;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notifications.map((item) {
                    return Column(
                      children: [
                        NotificationCard(data: {
                          "title": item["title"] ?? "",
                          "message": item["message"] ?? "No message",
                          "time": item["createdAt"] != null
                              ? timeago
                                  .format(DateTime.parse(item["createdAt"]))
                              : "Unknown time",
                          "isRead": item["isRead"] ?? true,
                        }),
                        spacer2(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
