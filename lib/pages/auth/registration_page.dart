import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/auth/confirmation_code_page.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer2(),
              Align(
                alignment: Alignment.center,
                child: Image.asset("assets/images/register1.png", height: 250),
              ),
              spacer2(),
              HeadingText("Create account"),
              spacer(),
              ParagraphText(
                "Enter the form below to open your\nnew account",
                textAlign: TextAlign.center,
              ),
              spacer2(),
              Row(
                children: [
                  ParagraphText("Username",
                      fontWeight: FontWeight.bold, textAlign: TextAlign.start),
                ],
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Create your username",
                  hintStyle: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
              ),
              spacer1(),
              Row(
                children: [
                  ParagraphText("Phone Number",
                      fontWeight: FontWeight.bold, textAlign: TextAlign.start),
                ],
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Enter your phone number here",
                  hintStyle: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
              ),
              spacer3(),
              customButton(
                onTap: () {
                  Get.to(() => ConfirmationCodePage());
                },
                text: "Register",
                width: double.infinity,
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ParagraphText("Already registered ? "),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginPage());
                    },
                    child: ParagraphText(
                      "Login",
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
