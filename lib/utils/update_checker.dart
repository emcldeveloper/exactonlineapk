// lib/utils/update_checker.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<Map<String, dynamic>> checkForUpdate() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 5), // Reduced timeout
      minimumFetchInterval: Duration(hours: 1), // Cache for 1 hour
    ));

    // Get the current app version first (this should always work)
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    String latestVersion = currentVersion; // Default to current version

    // Try to fetch remote config with timeout
    try {
      await remoteConfig.fetchAndActivate().timeout(Duration(seconds: 8));
      String remoteVersion = remoteConfig.getString('latest_version');
      if (remoteVersion.isNotEmpty) {
        latestVersion = remoteVersion;
      }
    } catch (e) {
      print('Remote config fetch failed: $e');
      // Continue with current version as latest version
    }

    final appStoreUrl = "https://apps.apple.com/app/your-app-id";
    final playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.exactonline.exactonline";

    return {
      "currentVersion": currentVersion,
      "latestVersion": latestVersion,
      "playStoreUrl": playStoreUrl,
      "appStoreUrl": appStoreUrl
    };
  } catch (e) {
    print('Update check failed: $e');
    // Return default values if everything fails
    return {
      "currentVersion": "1.0.0",
      "latestVersion": "1.0.0",
      "playStoreUrl":
          "https://play.google.com/store/apps/details?id=com.exactonline.exactonline",
      "appStoreUrl": "https://apps.apple.com/app/your-app-id"
    };
  }
}
