import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class JoinAsSellerPage extends StatelessWidget {
  const JoinAsSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> sellerAdvantages = [
      {"adv": "List your products on the platform "},
      {"adv": "Promote your products on the platform"},
      {"adv": "Share you products to other people"},
      {"adv": "Drive sales to your business"},
      {"adv": "Get insights about viewers of your products"},
      {"adv": "Get overall insights: impressions, clicks, profile views, calls"},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
       appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: secondaryColor,
              ),
            )),
        title: ParagraphText("Join as seller"),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/sellers_bg.png", height: 80.0),
            spacer1(),
            HeadingText("Are you a seller ?"),
            spacer(),
            ParagraphText(
                "Explore all possibilities you can unlock by joining E-Online platform as a seller"),
            spacer2(),
            Column(
              children: sellerAdvantages.map((item) {
                return Row(
                  children: [
                    Icon(AntDesign.check_circle_fill, color: Colors.green),
                    SizedBox(width: 5),
                    ParagraphText(item['adv'] ?? ""),
                  ],
                );
              }).toList(),
            ),
            spacer3(),
            customButton(
              onTap: () {
                Get.to(() => HomePage());
              },
              text: "Join Now",
            ),
          ],
        ),
      ),
    );
  }
}
