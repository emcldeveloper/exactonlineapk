import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ShopController extends GetxController {
  Future loadUserShop(id) async {
    try {
      var response = await dio.get("/shops/user/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data;
      print(data);
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error creating shop account",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
      print("Error creating shop account: ${e.response}");
    }
  }

  Future createShop(var payload) async {
    try {
      var response = await dio.post("/shops/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      var data = response.data;
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error creating shop account",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
      print("Error creating shop account: ${e.response}");
    }
  }

  Future createShopDocuments(payload) async {
    try {
      var response = await dio.post("/shop-documents/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      var data = response.data;
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error sending documents",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
      print("Error sending documents: ${e.response}");
    }
  }
}
