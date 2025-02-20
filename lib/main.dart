import 'dart:async';
import 'package:e_online/firebase_options.dart';
import 'package:e_online/pages/auth/onboarding_pages.dart';
import 'package:e_online/pages/error_page.dart';
import 'package:e_online/pages/splashscreen_page.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Background message handler (must be top-level)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 [Background] Message received: ${message.messageId}");
  print("🔹 Title: ${message.notification?.title}");
  print("🔹 Body: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestNotificationPermission();
  await getToken();
  setupFirebaseMessagingHandlers();

  runApp(const MyApp());
}

// 🔔 Request Notification Permissions
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("✅ User granted notification permission.");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("⚠️ User granted provisional permission.");
  } else {
    print("❌ User declined notification permission.");
  }

  // Allow notifications to show in the foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

// 🔑 Get FCM Token
Future<void> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("📌 FCM Token: $token");
}

// 🔥 Handle Firebase Messaging (Foreground, Background, Terminated)
void setupFirebaseMessagingHandlers() {
  // Foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 [Foreground] Message received!");
    print("🔹 Data: ${message.data}");

    if (message.notification != null) {
      print("🔹 Title: ${message.notification!.title}");
      print("🔹 Body: ${message.notification!.body}");
    }
  });

  // When app is opened from a terminated state (tap on notification)
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print("📩 [Terminated] App opened via notification: ${message.notification?.title}");
    }
  });

  // Background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ExactOnline",
      theme: ThemeData(
        primaryColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 4)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashscreenPage();
          }
          return const EntryPoint();
        },
      ),
    );
  }
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  Future<bool> _isOnboardingComplete() async {
    return SharedPreferencesUtil.isOnboardingSeen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          );
        }
        var result = snapshot.requireData;
        if (result == true) {
          return WayPage();
        }
        return const OnboardingPage();
      },
    );
  }
}
