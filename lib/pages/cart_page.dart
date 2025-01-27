import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/pages/my_orders_page.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    UsersControllers usersControllers = Get.find();
    usersControllers.user;
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("Submit Order"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Get.to(SettingMyshopPage(
                from: "shoppingPage",
              ));
            },
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: Colors.black,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 16),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer(),
              HeadingText("Selected products"),
              ParagraphText("You have selected 3 products",
                  color: mutedTextColor),
              spacer(),
              Column(
                children: productItems.map((item) {
                  return HorizontalProductCard(data: item);
                }).toList(),
              ),
              spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText("Total Price"),
                  ParagraphText("TZS 120,0000",
                      fontWeight: FontWeight.bold, fontSize: 17)
                ],
              ),
              spacer3(),
              customButton(
                onTap: () {
                  showPopupAlert(
                    context,
                    iconAsset: "assets/images/successmark.png",
                    heading: "Ordered successfully",
                    text: "Your order is submitted successfully",
                    button1Text: "Shop",
                    button1Action: () {
                      Navigator.of(context).pop(); // Close the second popup
                      Get.to(const HomePage());
                    },
                    button2Text: "View orders",
                    button2Action: () {
                      Navigator.of(context)
                          .pop(); // Close the second popup and perform any additional action
                      Get.to(const MyOrdersPage());
                    },
                  );
                },
                text: "Submit Order",
              ),
              spacer3(),
            ],
          ),
        ),
      ),
    );
  }
}
