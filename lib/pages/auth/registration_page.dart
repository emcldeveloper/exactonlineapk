import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/pages/auth/confirmation_code_page.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});
  var isLoading = false.obs;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

                      final payload = {"name": username, "phone": phone};

                      try {
                        await authController.registerUser(payload);
                        isLoading.value = false;
                        Get.to(() => ConfirmationCodePage(phoneNumber: phone));
                      } catch (e) {
                        isLoading.value = false;
                        Get.snackbar("Error", e.toString(),
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: Colors.white));
                      }
                    }
                  },
                  text: isLoading.value ? null : "Register",
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
