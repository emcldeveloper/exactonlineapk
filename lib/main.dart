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

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase services with error handling
    try {
      await setupFirebaseMessaging();
      await initializeFirebaseMessaging();
      await getToken();
    } catch (e) {
      print('Firebase messaging initialization failed: $e');
      // Continue without messaging if it fails
    }

    // Initialize local notifications
    try {
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print('Local notifications initialization failed: $e');
      // Continue without local notifications if it fails
    }

    // setup crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } catch (e) {
        print('Crashlytics error: $e');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (e) {
        print('Crashlytics error: $e');
      }
      return true;
    };
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase if it fails
  }

  runApp(const MyApp());
}

// 🔑 Get FCM Token
Future<void> getToken() async {
  try {
    String? token = await FirebaseMessaging.instance
        .getToken()
        .timeout(Duration(seconds: 5));
    print("📌 FCM Token: $token");
  } catch (e) {
    print("FCM Token fetch failed: $e");
  }
}

final UserController userController = Get.put(UserController());

Future<bool> checkIfUserIsLoggedIn() async {
  try {
    String? token = await SharedPreferencesUtil.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        var response = await userController
            .getUserDetails()
            .timeout(Duration(seconds: 10));
        var userDetails = response["body"];
        print(userDetails);

        userController.user.value = userDetails;
        return true;
      } catch (e) {
        print('User details fetch failed: $e');
        await SharedPreferencesUtil.removeAccessToken();
        // Don't navigate here as it might cause issues during app startup
        return false;
      }
    }
    return false;
  } catch (e) {
    print('Login check failed: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  const MyApp({super.key});

  void trackAppOpen() {
    analytics.logEvent(name: 'app_opened');
  }

  // Compare two version strings (e.g., "1.2.3" vs "1.2.4")
  // Returns true if latestVersion is greater than currentVersion
  bool _isVersionGreater(String latestVersion, String currentVersion) {
    try {
      print(latestVersion);
      print(currentVersion);
      // Remove any non-numeric characters except dots
      String cleanLatest = latestVersion.replaceAll(RegExp(r'[^0-9.]'), '');
      String cleanCurrent = currentVersion.replaceAll(RegExp(r'[^0-9.]'), '');

      List<int> latest =
          cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> current =
          cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      // Ensure both lists have the same length by padding with zeros
      int maxLength =
          latest.length > current.length ? latest.length : current.length;

      while (latest.length < maxLength) latest.add(0);
      while (current.length < maxLength) current.add(0);

      // Compare version numbers
      for (int i = 0; i < maxLength; i++) {
        if (latest[i] > current[i]) {
          return true; // Latest version is greater
        } else if (latest[i] < current[i]) {
          return false; // Current version is greater
        }
        // If equal, continue to next part
      }

      return false; // Versions are equal
    } catch (e) {
      print("Error comparing versions: $e");
      // If there's an error parsing, fall back to string comparison
      return latestVersion != currentVersion;
    }
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
                    // print(results);

                    // Only show update page if latestVersion is greater than currentVersion
                    bool shouldUpdate = _isVersionGreater(
                        results["latestVersion"], results["currentVersion"]);

                    return shouldUpdate
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
