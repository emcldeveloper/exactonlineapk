import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/pages/auth/confirmation_code_page.dart';
import 'package:e_online/pages/auth/registration_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  UsersControllers usersControllers = UsersControllers();
  var isLoading = false.obs;
  final TextEditingController phoneController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
              Form(
                  key: _formKey,
                  child: Column(children: [
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
                  ])),
              spacer3(),
              Obx(() {
                return customButton(
                  onTap: () async {
                    if (_formKey.currentState?.validate() == true) {
                      isLoading.value = true;
                      final phone = phoneController.text;
                      final payload = {"phone": phone};

                      try {
                        await authController.sendUserCode(payload);
                        isLoading.value = false;
                        await analytics.logEvent(
                            name: 'login',
                            parameters: {'method': 'phone', 'phone': phone});

                        Get.to(() => ConfirmationCodePage(phoneNumber: phone));
                      } catch (e) {
                        isLoading.value = false;
                        Get.snackbar("Failed to Login", "User Not Found",
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: Colors.white));
                      }
                    }
                  },
                  text: isLoading.value ? null : "Login",
                  width: double.infinity,
                  child: isLoading.value
                      ? const CustomLoader(
                          color: Colors.white,
                        )
                      : null,
                );
              }),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ParagraphText("Don`t have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => RegistrationPage());
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
