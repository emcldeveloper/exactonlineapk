import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/pages/seller_order_view_page.dart';
import 'package:e_online/utils/local_notifications_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

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
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    var data = message.data;
    if (data["type"] == "order") {
      OrdersController().getOrder(id: data["orderId"]).then((order) {
        if (order != null) {
          if (data["to"] == "user") {
            Get.to(() => CustomerOrderViewPage(order: order));
          } else {
            Get.to(() => SellerOrderViewPage(order: order));
          }
        } else {
          print("Order not found");
          return;
        }
      });
    }
    print('Notification clicked: ${message.data}');
  });
}
