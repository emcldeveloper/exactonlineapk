import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
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
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    String username = userController.user["name"] ?? "No name";
    String phone = userController.user["phone"] ?? "0";
    String avatar = userController.user["image"] ?? 'assets/images/avatar.png';
    List<dynamic>? shops = userController.user["Shops"];
    bool hasShop = shops != null && shops.isNotEmpty;

    final List<Map<String, dynamic>> settingItems = [
      if (hasShop)
        {
          'icon': Bootstrap.cart,
          'title': 'My Shop',
          'page': const FreeTrialPage(),
        },
      {
        'icon': Bootstrap.bag,
        'title': 'My Orders',
        'page': const MyOrdersPage(),
      },
      {
        'icon': Icons.edit_outlined,
        'title': 'Edit Profile',
        'page': EditProfilePage(),
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'Customer Support',
        'page': FontAwesome.circle_question,
      },
      {
        'icon': Icons.assignment_outlined,
        'title': 'Terms and Conditions',
        'page': const TermsConditionsPage(),
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'page': const PrivacyPolicy(),
      },
    ];

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: HeadingText("My Profile"),
        centerTitle: false,
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
            children: [
              GestureDetector(
                onTap: () => {Get.to(() => EditProfilePage())},
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Stack(
                    children: [
                      ClipOval(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUserCircle,
                          color: Colors.black,
                          size: 80,
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
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedPencilEdit02,
                                color: Colors.white,
                                size: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              spacer1(),
              HeadingText(username),
              ParagraphText(phone),
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
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            color: Colors.black,
                            size: 20.0,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child:
                                  ParagraphText(item['title'], fontSize: 15)),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              spacer1(),
              if (!hasShop)
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
                      Image.asset("assets/images/sellers.png", height: 80.0),
                      spacer1(),
                      HeadingText("Join ExactOnline as a seller",
                          fontSize: 18.0),
                      spacer(),
                      ParagraphText(
                        "List your products and drive sales to your\nbusiness using ExactOnline",
                        fontSize: 14.0,
                        textAlign: TextAlign.center,
                      ),
                      spacer2(),
                      customButton(
                        onTap: () {
                          Get.to(() => const JoinAsSellerPage());
                        },
                        text: "Learn More",
                        vertical: 15.0,
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
