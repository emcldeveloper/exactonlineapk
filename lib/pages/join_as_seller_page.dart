import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/register_as_seller_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class JoinAsSellerPage extends StatelessWidget {
  const JoinAsSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "JoinAsSellerPage",
        screenClass: "JoinAsSellerPage",
      );
    });
    List<Map<String, String>> sellerAdvantages = [
      {"adv": "List your products on the platform"},
      {"adv": "Promote your products on the platform"},
      {"adv": "Share your products with other people"},
      {"adv": "Drive sales to your business"},
      {"adv": "Get insights about viewers of your products"},
      {
        "adv": "Get overall insights: impressions, clicks, profile views, calls"
      },
    ];

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
        title: HeadingText("Join as seller"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/sellers.png",
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                    spacer1(),
                    HeadingText("Are you a seller?"),
                    spacer(),
                    ParagraphText(
                      "Explore all possibilities you can unlock by\njoining ExactOnline platform as a seller",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              spacer2(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sellerAdvantages.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          color: Colors.green,
                          size: 22.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ParagraphText(item['adv'] ?? ""),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              spacer3(),
              customButton(
                onTap: () {
                  Get.to(() => const RegisterAsSellerPage());
                },
                text: "Join Now",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
