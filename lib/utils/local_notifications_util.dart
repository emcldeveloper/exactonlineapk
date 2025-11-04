import 'dart:convert';
import 'package:e_online/utils/app_badge_util.dart';
import 'package:e_online/utils/notification_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize the plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification'); // Use your app icon
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      try {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(payload);
          AppBadgeUtil.clear();
          handleNotificationNavigation(data);
        }
      } catch (_) {}
    },
  );

  // Request permissions for Android 13+ and iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

// Function to show local notification
Future<void> showLocalNotification(RemoteMessage message) async {
  final int nextBadge = AppBadgeUtil.count + 1;
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    channelDescription: 'Channel for high priority notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    channelShowBadge: true,
    number: nextBadge,
  );
  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    platformChannelSpecifics,
    payload: jsonEncode(message.data), // JSON payload for tap handling
  );

  // Do not update app icon badge here; only update badge when app is not opened (handled in background handler)
}
