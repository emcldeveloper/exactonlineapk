import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  final String playStoreUrl;
  final String appStoreUrl;

  const UpdatePage({
    super.key,
    required this.playStoreUrl,
    required this.appStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "UpdatePage",
        screenClass: "UpdatePage",
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.system_update, size: 80, color: Colors.orange),
                const SizedBox(height: 16),
                HeadingText(
                  "Update Required",
                  textAlign: TextAlign.center,
                  fontSize: 28.0,
                ),
                const SizedBox(height: 10),
                ParagraphText(
                  "A new version of the app is available. Please update to continue using.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                customButton(
                  text: "Update Now",
                  onTap: () {
                    String url =
                        Platform.isAndroid ? playStoreUrl : appStoreUrl;
                    launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                customButton(
                    onTap: () => exit(0),
                    textColor: Colors.black,
                    buttonColor: Colors.grey[100],
                    text: "Not Now"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
