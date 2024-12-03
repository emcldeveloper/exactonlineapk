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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: mutedTextColor,
                size: 14.0,
              ),
            )),
        title: HeadingText("Edit Profile"),
        centerTitle: true,
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
              ParagraphText(
                "Username",
                fontWeight: FontWeight.bold,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Enter business name",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer(),
              ParagraphText(
                "Phone number",
                fontWeight: FontWeight.bold,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Enter phone number",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer(),
              ParagraphText(
                "Email address (optional)",
                fontWeight: FontWeight.bold,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Enter business address",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer1(),
              customButton(
                onTap: () {
                  Get.to(() => ProfilePage());
                },
                text: "Save Changes",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
