import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/customer_support_page.dart';
import 'package:e_online/pages/edit_profile_page.dart';
import 'package:e_online/pages/free_trial_page.dart';
import 'package:e_online/pages/join_as_seller_page.dart';
import 'package:e_online/pages/my_orders_page.dart';
import 'package:e_online/pages/privacy_policy.dart';
import 'package:e_online/pages/terms_conditions_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingItems = [
      {
        'icon': AntDesign.shop_outline,
        'title': 'My Shop',
        'page': const FreeTrialPage(),
      },
      {
        'icon': AntDesign.shopping_outline,
        'title': 'My Orders',
        'page': const MyOrdersPage(),
      },
      {
        'icon': AntDesign.user_outline,
        'title': 'Edit Profile',
        'page': const EditProfilePage(),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Customer Support',
        'page': const CustomerSupportPage(),
      },
      {
        'icon': Icons.motorcycle,
        'title': 'Terms and Conditions',
        'page': const TermsConditionsPage(),
      },
      {
        'icon': AntDesign.setting_outline,
        'title': 'Privacy Policy',
        'page': PrivacyPolicy(),
      },
    ];

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: HeadingText("My Profile"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        "assets/images/avatar.png",
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Icon(
                            AntDesign.edit_outline,
                            color: Colors.white,
                            size: 22.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              spacer1(),
              HeadingText("Robinson Jesca"),
              ParagraphText("0627707434"),
              spacer(),
              Row(
                children: [HeadingText("Settings", textAlign: TextAlign.start)],
              ),
              spacer(),
              Column(
                children: settingItems.map((item) {
                  return InkWell(
                    onTap: () {
                      Get.to(() => item['page'] as Widget);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(item['icon']),
                          const SizedBox(width: 10),
                          Expanded(child: ParagraphText(item['title'])),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              spacer1(),
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/sellers_bg.png", height: 80.0),
                    spacer1(),
                    HeadingText("Join E-Online as a seller"),
                    spacer(),
                    ParagraphText(
                      "List your products and drive sales to your\nbusiness using E-Online",
                      textAlign: TextAlign.center,
                    ),
                    spacer2(),
                    customButton(
                      onTap: () {
                        Get.to(() => const JoinAsSellerPage());
                      },
                      text: "Learn More",
                      vertical: 8.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
