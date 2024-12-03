import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/pages/join_as_seller_page.dart';
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
        'icon': AntDesign.user_outline,
        'title': 'Edit Profile',
        'page': ProfilePage(),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Customer Support',
        'page': LoginPage(),
      },
      {
        'icon': Icons.motorcycle,
        'title': 'Terms and Conditions',
        'page': ProfilePage(),
      },
      {
        'icon': AntDesign.setting_outline,
        'title': 'Privacy Policy',
        'page': ProfilePage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new_outlined, color: secondaryColor),
        ),
        title: HeadingText("My Profile"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipOval(
                child: Container(
                  height: 80,
                  width: 80,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/avatar.png",
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          AntDesign.edit_fill,
                          color: Colors.black,
                          size: 24.0,
                        ),
                      ),
                    ],
                  ),
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
                  return GestureDetector(
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
                          Icon(Icons.arrow_forward_ios),
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
                        Get.to(() => JoinAsSellerPage());
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
