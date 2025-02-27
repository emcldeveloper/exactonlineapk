import 'dart:async';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/firebase_options.dart';
import 'package:e_online/pages/auth/onboarding_pages.dart';
import 'package:e_online/pages/splashscreen_page.dart';
import 'package:e_online/pages/update_page.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/update_checker.dart';
import 'package:e_online/widgets/network_listener.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_links5/uni_links.dart';
import 'package:flutter/foundation.dart';

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

  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
      print(
          "📩 [Terminated] App opened via notification: ${message.notification?.title}");
    }
  });

  // Background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

final UserController userController = Get.put(UserController());

Future<bool> checkIfUserIsLoggedIn() async {
  String? token = await SharedPreferencesUtil.getAccessToken();
  if (token != null && token.isNotEmpty) {
    try {
      var response = await userController.getUserDetails();
      var userDetails = response["body"];
      print(userDetails);

      userController.user.value = userDetails;
      return true;
    } catch (e) {
      await SharedPreferencesUtil.removeAccessToken();
      Get.offAll(() => WayPage());
    }
  }
  return false;
}

void _handleDeepLink(Uri? uri) async {
  if (uri != null) {
    String? productId = uri.queryParameters['productId'];
    String? shopId = uri.queryParameters['shopId'];

    bool isLoggedIn = await checkIfUserIsLoggedIn();

    if (productId != null) {
      if (isLoggedIn) {
        Get.toNamed('/product', arguments: {'id': productId});
      } else {
        Get.toNamed('/login',
            arguments: {'redirect': '/product?id=$productId'});
      }
    } else if (shopId != null) {
      if (isLoggedIn) {
        Get.toNamed('/shop', arguments: {'id': shopId});
      } else {
        Get.toNamed('/login', arguments: {'redirect': '/shop?id=$shopId'});
      }
    }
  }
}

void initDeepLinkListener() {
  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      _handleDeepLink(uri);
    }
  });
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ExactOnline",
      navigatorObservers: [observer],
      theme: ThemeData(
        primaryColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: Stack(
        children: [
          // The main content of your app
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 4)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashscreenPage();
              }
              return FutureBuilder(
                  future: checkForUpdate(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                    Map<String, dynamic> results = snapshot.requireData;
                    print(results);
                    return results["currentVersion"] != results["latestVersion"]
                        ? UpdatePage(
                            playStoreUrl: results['playStoreUrl'],
                            appStoreUrl: results["appStoreUrl"],
                          )
                        : const EntryPoint();
                  });
            },
          ),
          // The connectivity listener widget, always on top if no internet.
          Center(
            child: NetworkListener(),
          ),
        ],
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
