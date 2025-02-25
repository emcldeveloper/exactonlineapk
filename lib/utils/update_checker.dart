// lib/utils/update_checker.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<Map<String, dynamic>> checkForUpdate() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration.zero, // Ensures fresh data is fetched
  ));

  // Fetch and activate the latest config
  await remoteConfig
      .fetchAndActivate(); // This ensures the latest values are fetched

  String latestVersion = remoteConfig.getString('latest_version');

  // Get the current app version
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  final appStoreUrl = "https://apps.apple.com/app/your-app-id";
  final playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.exactmanpower.e_online";

  return {
    "currentVersion": currentVersion,
    "latestVersion": latestVersion,
    "playStoreUrl": playStoreUrl,
    "appStoreUrl": appStoreUrl
  };
}
