import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/pages/subscription_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreeTrialPage extends StatelessWidget {
  const FreeTrialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: HeadingText(
          "14 days Free Trial",
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer1(),
              Image.asset(
                "assets/images/trialillustration.png",
                height: 250,
                fit: BoxFit.contain,
              ),
              spacer(),
              HeadingText(
                "Start Your 14-Day Free\nTrial Today!",
                textAlign: TextAlign.center,
              ),
              spacer1(),
              ParagraphText(
                "Take your business to the next levelwith our 14-day free trial. Explore powerful tools to list products, manage your store, and connect with our customers--all with no commitment. Start growing your sales today, risk free!",
                color: mutedTextColor,
                textAlign: TextAlign.center,
              ),
              spacer2(),
              spacer3(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    customButton(
                      onTap: () => Get.to(() => const MyShopPage()),
                      text: "Start 14 days free trial",
                    ),
                    spacer1(),
                    customButton(
                      onTap: () => Get.to(() => const SubscriptionPage()),
                      text: "Explore our packages",
                      buttonColor: primaryColor,
                      textColor: Colors.black,
                    ),
                  ],
                ),
              ),
              spacer1(),
            ],
          ),
        ),
      ),
    );
  }
}
