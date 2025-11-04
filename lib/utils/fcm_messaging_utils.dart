import 'package:e_online/utils/app_badge_util.dart';
import 'package:e_online/utils/notification_router.dart';
import 'package:e_online/utils/local_notifications_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebaseMessaging() async {
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications (iOS prompts user)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // Get the device token
  String? token = await messaging.getToken();
  print('Device Token: $token');

  // Save the token to your backend or database
  // Example: Send token to your Node.js server via an API call
}

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Notification Data: ${message.data}');
  // Increment app badge count for background messages
  await AppBadgeUtil.increment();
}

Future<void> setupFirebaseMessaging() async {
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize local notifications
  await initLocalNotifications();

  // Request permission
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      showLocalNotification(message); // Show local notification
    }
  });

  // Handle background and terminated states
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Handle notification taps when app in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await AppBadgeUtil.clear();
    await handleNotificationNavigation(message.data);
    print('Notification clicked: ${message.data}');
  });

  // Handle notification when app was terminated
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    await AppBadgeUtil.clear();
    await handleNotificationNavigation(initialMessage.data);
  }
}
