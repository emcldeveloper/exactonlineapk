// lib/utils/update_checker.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<void> checkForUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration.zero, // Always fetch latest
  ));

  await remoteConfig.fetchAndActivate();

  String latestVersion =
      remoteConfig.getString('latest_version'); // Set this in Firebase
  print("latest_version");
  print(latestVersion);
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  final appStoreUrl =
      "https://apps.apple.com/app/your-app-id"; // Replace with your App Store URL
  final playStoreUrl =
      "https://play.google.com/store/apps/details?id=your.package.name"; // Replace with your Play Store URL

  if (currentVersion != latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without update
      builder: (context) => AlertDialog(
        title: Text("Update Required"),
        content: Text("A new version of the app is available. Please update."),
        actions: [
          TextButton(
            onPressed: () => exit(0), // Exit the app if the user refuses
            child: const Text("Not Now"),
          ),
          TextButton(
            onPressed: () {
              String url = Platform.isAndroid ? playStoreUrl : appStoreUrl;
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: Text("Update Now"),
          ),
        ],
      ),
    );
  }
}
