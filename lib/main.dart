import 'dart:async';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/firebase_options.dart';
import 'package:e_online/pages/auth/onboarding_pages.dart';
import 'package:e_online/pages/splashscreen_page.dart';
import 'package:e_online/pages/update_page.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/utils/fcm_messaging_utils.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/update_checker.dart';
import 'package:e_online/widgets/network_listener.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:uni_links5/uni_links.dart';
import 'package:flutter/foundation.dart';

// Background message handler (must be top-level)

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFirebaseMessaging();
  await initializeFirebaseMessaging();
  await getToken();

// Initialize local notifications
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // setup crashlytics
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

// 🔑 Get FCM Token
Future<void> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("📌 FCM Token: $token");
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

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  const MyApp({super.key});

  void trackAppOpen() {
    analytics.logEvent(name: 'app_opened');
  }

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
                      return const Scaffold(
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
