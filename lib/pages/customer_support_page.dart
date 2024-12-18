import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              spacer1(),
              HeadingText("Do you need help ?"),
              spacer(),
              ParagraphText(
                "Contact us via +255627707434 or press the button below to reach use via our whatsapp number",
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              customButton(
                onTap: () {
                  Get.to(() => ChatPage());
                },
                text: "Chat on whatsappp",
              ),
              spacer3()
            ],
          ),
        ),
      ),
    );
  }
}
