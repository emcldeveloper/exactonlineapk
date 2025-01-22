import 'package:e_online/utils/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class AuthController extends GetxController {
  Future registerUser(Map<String, dynamic> payload) async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/",
        data: payload,
      );
      var data = response.data["body"]["message"];
      return data;
    } catch (e) {
      print(e);
      Get.snackbar("Failed to Register User", "User Already Exists",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
    }
  }

  Future verifyUserCode(Map<String, dynamic> payload) async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/auth/verify-code",
        data: payload,
      );
      var data = response.data;
      return data;
    } catch (e) {
      print(e);
      Get.snackbar("Failed to Verify Code", "Wrong code Provided",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
    }
  }

  Future sendUserCode(Map<String, dynamic> payload) async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/auth/send-code",
        data: payload,
      );
      var data = response.data;
      return data;
    } catch (e) {
      print(e);
      Get.snackbar("Failed to Login", "User Not Found",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
    }
  }
}
