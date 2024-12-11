import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/pages/auth/resend_confirmation_code_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ConfirmationCodePage extends StatelessWidget {
  const ConfirmationCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    String phoneNumber = "0712345678";

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
                child:
                    Image.asset("assets/images/verification1.png", height: 250),
              ),
              spacer1(),
              HeadingText("Verify your number"),
              ParagraphText("Enter verification code we sent to\n$phoneNumber",
                  textAlign: TextAlign.center),
              spacer2(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText("Verification Code"),
                  ParagraphText("2:56"),
                ],
              ),
              spacer(),
              Form(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: PinCodeTextField(
                    length: 5,
                    appContext: context,
                    obscureText: false,
                    controller: TextEditingController(),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      inactiveColor: Colors.grey,
                      activeColor: secondaryColor,
                      selectedColor: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 60,
                      fieldWidth: 60,
                      activeFillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              spacer3(),
              customButton(
                  onTap: () {
                    Get.to(() => ResendConfirmationCodePage());
                  },
                  text: "Verify Account"),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ParagraphText("Need to go back ? "),
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
