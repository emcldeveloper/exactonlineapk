import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

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
            )),
        title: HeadingText("Edit Profile"),
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
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
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
              spacer1(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                    "Username",
                    fontWeight: FontWeight.bold,
                  ),
                  spacer(),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      fillColor: primaryColor,
                      filled: true,
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintText: "Enter business name",
                      hintStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                  spacer(),
                  ParagraphText(
                    "Phone number",
                    fontWeight: FontWeight.bold,
                  ),
                  spacer(),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      fillColor: primaryColor,
                      filled: true,
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintText: "Enter phone number",
                      hintStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                  spacer(),
                  ParagraphText(
                    "Email address (optional)",
                    fontWeight: FontWeight.bold,
                  ),
                  spacer(),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      fillColor: primaryColor,
                      filled: true,
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintText: "Enter business address",
                      hintStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ],
              ),
              spacer3(),
              customButton(
                onTap: () {},
                text: "Save Changes",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
