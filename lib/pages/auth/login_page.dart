import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/auth/registration_page.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/login_bg.png", height: 80),
            spacer1(),
            HeadingText("Login to continue"),
            spacer(),
            ParagraphText(
                "Enter your phone number and click send code to receive verification code"),
            spacer2(),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Phone Number"),
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
                hintText: "Enter your phone number here",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer3(),
            customButton(
                onTap: () {
                  Get.to(() => RegistrationPage());
                },
                text: "Login"),
            spacer(),
            Row(
              children: [
                ParagraphText("Don’t have an account ?"),
                SizedBox(
                  width: 5,
                ),
                ParagraphText("Register"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
