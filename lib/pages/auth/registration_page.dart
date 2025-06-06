import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/pages/auth/confirmation_code_page.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});
  var isLoading = false.obs;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "RegistrationPage",
        screenClass: "RegistrationPage",
      );
    });

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
                child: Image.asset("assets/images/register2.avif", height: 250),
              ),
              spacer2(),
              HeadingText("Create account"),
              spacer(),
              ParagraphText(
                "Enter the form below to open your\nnew account",
                textAlign: TextAlign.center,
              ),
              spacer2(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ParagraphText("Username",
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.start),
                      ],
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username cannot be empty";
                        }
                        if (value.length < 3) {
                          return "Username must be at least 3 characters long";
                        }
                        return null;
                      },
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
                        hintText: "Create your username",
                        hintStyle:
                            TextStyle(color: mutedTextColor, fontSize: 12),
                      ),
                    ),
                    spacer1(),
                    Row(
                      children: [
                        ParagraphText("Phone Number",
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.start),
                      ],
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number cannot be empty";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return "Enter a valid phone number";
                        }
                        return null;
                      },
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
                        hintStyle:
                            TextStyle(color: mutedTextColor, fontSize: 12),
                      ),
                    ),
                    spacer1(),
                    Row(
                      children: [
                        ParagraphText("Email Address",
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.start),
                      ],
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
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
                        hintText: "Enter your email here",
                        hintStyle:
                            TextStyle(color: mutedTextColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              spacer3(),
              Obx(() {
                return customButton(
                    onTap: () async {
                      if (_formKey.currentState?.validate() == true) {
                        isLoading.value = true;
                        final username = usernameController.text;
                        final phone = phoneController.text;
                        final email = emailController.text;

                        final payload = {
                          "name": username,
                          "phone": phone,
                          "email": email
                        };

                        try {
                          await authController.registerUser(payload);
                          isLoading.value = false;
                          await analytics.logEvent(name: 'login', parameters: {
                            'method': 'email',
                            'name': username,
                            'phone': phone
                          });
                          Get.to(
                              () => ConfirmationCodePage(phoneNumber: phone));
                        } catch (e) {
                          isLoading.value = false;
                          Get.snackbar(
                              "Failed to Register User", "User Already Exists",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: Colors.white));
                        }
                      }
                    },
                    text: isLoading.value ? null : "Register",
                    width: double.infinity,
                    loading: isLoading.value);
              }),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ParagraphText("Already registered ? "),
                  const SizedBox(width: 5),
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
