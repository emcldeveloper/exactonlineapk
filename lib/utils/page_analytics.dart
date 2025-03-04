import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void trackScreenView(String screenName) {
  analytics.logScreenView(
    screenName: screenName,
    screenClass: screenName,
  );
}
