import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "CustomerSupportPage",
        screenClass: "CustomerSupportPage",
      );
    });
    const phoneNumber = "+255627707434";
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Container(
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back_ios,
              color: mutedTextColor,
              size: 16.0,
            ),
          ),
        ),
        title: HeadingText("Customer support"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer1(),
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedHeadset,
                      color: Colors.black,
                      size: 80.0,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Brand(
                        Brands.whatsapp,
                        size: 22.0,
                      ),
                    ),
                  ],
                ),
              ),
              spacer1(),
              HeadingText("Do you need help ?"),
              spacer(),
              ParagraphText(
                "Contact us via $phoneNumber or press the button below to reach use via our whatsapp number",
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              customButton(
                onTap: () async {
                  // Replace with your WhatsApp number
                  const message =
                      "Hello, I need help with..."; // Optional pre-filled message
                  final whatsappUrl =
                      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

                  if (await canLaunchUrlString(whatsappUrl)) {
                    await launchUrlString(whatsappUrl);
                  } else {
                    Get.snackbar(
                      "Error",
                      "Could not open WhatsApp",
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      icon: const Icon(Icons.error, color: Colors.white),
                    );
                  }
                },
                text: "Chat on WhatsApp",
              ),
              spacer3()
            ],
          ),
        ),
      ),
    );
  }
}
