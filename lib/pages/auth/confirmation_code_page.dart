import 'dart:async';

import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String phoneNumber;
  const ConfirmationCodePage({super.key, required this.phoneNumber});
  @override
  State<ConfirmationCodePage> createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  var isLoading = false.obs;
  var iResendLoading = false.obs;
  final AuthController authController = Get.put(AuthController());
  final TextEditingController passcodeController = TextEditingController();

  int _minutes = 0;
  int _seconds = 30;
  Timer? _timer;
  bool _showResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            _timer?.cancel();
            _showResend = true;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    String min = _minutes.toString().padLeft(1, '0');
    String sec = _seconds.toString().padLeft(2, '0');
    return "$min:$sec";
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
                child:
                    Image.asset("assets/images/verification1.png", height: 250),
              ),
              spacer1(),
              HeadingText("Verify your number"),
              ParagraphText(
                  "Enter verification code we sent to\n${widget.phoneNumber}",
                  textAlign: TextAlign.center),
              spacer2(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText("Verification Code"),
                  Obx(() {
                    if (iResendLoading.value) {
                      return CustomLoader(
                        size: 15.0,
                        color: Colors.black,
                      );
                    }
                    return _showResend
                        ? InkWell(
                            onTap: () async {
                              iResendLoading.value = true;
                              final payload = {"phone": widget.phoneNumber};
                              try {
                                final response =
                                    await authController.sendUserCode(payload);
                                iResendLoading.value = false;
                                if (response['status'] == true) {
                                  Get.snackbar(
                                      "Success", "Verification code sent.",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      icon: HugeIcon(
                                          icon: HugeIcons.strokeRoundedTick01,
                                          color: Colors.white));
                                  setState(() {
                                    _minutes = 0;
                                    _seconds = 30;
                                    _showResend = false;
                                  });
                                  _startTimer();
                                } else {
                                  String errorMessage =
                                      response['body']['message'];
                                  Get.snackbar("Error", errorMessage,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      icon: HugeIcon(
                                          icon: HugeIcons.strokeRoundedCancel01,
                                          color: Colors.white));
                                }
                              } catch (e) {
                                iResendLoading.value = false;
                                Get.snackbar(
                                    "Error", "Resend verification Code Failed",
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    icon: HugeIcon(
                                        icon: HugeIcons.strokeRoundedCancel01,
                                        color: Colors.white));
                              }
                            },
                            child: ParagraphText(
                              "Resend Code",
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : ParagraphText(_formatTime());
                  }),
                ],
              ),
              spacer(),
              Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PinCodeTextField(
                    length: 6,
                    controller: passcodeController,
                    appContext: context,
                    obscureText: false,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      inactiveColor: Colors.grey,
                      activeColor: secondaryColor,
                      selectedColor: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              spacer3(),
              Obx(() {
                return customButton(
                  onTap: () async {
                    isLoading.value = true;
                    final passcode = passcodeController.text;
                    final payload = {
                      "phone": widget.phoneNumber,
                      "passcode": passcode
                    };
                    try {
                      final response =
                          await authController.verifyUserCode(payload);
                      if (response['status'] == true) {
                        isLoading.value = false;
                        String accessToken = response['body']['ACCESS_TOKEN'];
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('ACCESS_TOKEN', accessToken);
                        Get.to(() => WayPage());
                      } else {
                        isLoading.value = false;
                        String errorMessage = response['body']['message'];
                        Get.snackbar("Verification Failed", errorMessage,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: Colors.white));
                      }
                    } catch (e) {
                      isLoading.value = false;
                      Get.snackbar(
                          "Failed to Verify Code", "Wrong code Provided",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: Colors.white));
                    }
                  },
                  text: isLoading.value ? null : "Verify Account",
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
                  ParagraphText("Need to go back ? "),
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
