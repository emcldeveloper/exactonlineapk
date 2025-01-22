import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/pages/auth/registration_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UsersControllers usersControllers = UsersControllers();
  @override
  void initState() {
    // TODO: implement initState
    Get.put(usersControllers);

    super.initState();
  }

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
                child: Image.asset("assets/images/login1.png", height: 250),
              ),
              spacer2(),
              HeadingText("Login to continue"),
              spacer(),
              ParagraphText(
                "Enter your phone number and click\nsend code to receive verification\ncode",
                textAlign: TextAlign.center,
              ),
              spacer2(),
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
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: 12),
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
                    borderSide: const BorderSide(
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
                  usersControllers.registerUser(());
                  usersControllers.user = "jkasdlfjasldfjas";
                  Get.to(() => const RegistrationPage());
                },
                text: "Login",
                width: double.infinity,
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ParagraphText("Don`t have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RegistrationPage());
                    },
                    child: ParagraphText(
                      "Register",
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
