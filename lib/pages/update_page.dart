import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
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
                  "A new version of the app is available. Please update to continue using all features.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customButton(
                      onTap: () => exit(0),
                      child: const Text("Not Now"),
                    ),
                    customButton(
                      onTap: () {
                        String url =
                            Platform.isAndroid ? playStoreUrl : appStoreUrl;
                        launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text("Update Now"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
