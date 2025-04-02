// ignore_for_file: unused_import, prefer_typing_uninitialized_variables

import 'package:dio/dio.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ShopController extends GetxController {
  UserController userController = Get.find();
  Future loadUserShops(id) async {
    try {
      var response = await dio.get("/shops/user/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data;
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error creating shop account",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      throw Exception(e);
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
      throw Exception(e);
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
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      throw Exception(e);
    }
  }

  Future getShopDetails(id) async {
    try {
      var shopId;
      if (id == null) {
        shopId = await SharedPreferencesUtil.getSelectedBusiness();
        if (shopId == null) {
          shopId = userController.user.value["Shops"][0]["id"];
          await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
        }
      } else {
        shopId = id;
      }
      var response = await dio.get("/shops/$shopId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error loading shop details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      throw Exception(e);
    }
  }

  Future updateShopData(id, payload) async {
    try {
      var response = await dio.patch("/shops/$id",
          data: payload,
          options: Options(
            headers: {
              "Authorization":
                  "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
            },
          ));
      var data = response.data;
      Get.snackbar("Success", "Shop updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
      return data;
    } on DioException {
      Get.snackbar("Error", "Error updating shop details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01, color: Colors.white));
    }
  }

  Future deleteShop(id) async {
    try {
      var response = await dio.get("/shops/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data;
      Get.snackbar("Success", "Shop deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error deleting shop account",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      throw Exception(e);
    }
  }

  Future createShopCalendar(var payload) async {
    try {
      var response = await dio.post(
        "/shop-calenders/",
        data: payload,
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
        }),
      );
      var data = response.data;

      return data;
    } on DioException {
      // Show a Snackbar with the error
      Get.snackbar("Error", "Error creating Shop-Calendar",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      // Do not re-throw the exception to avoid crashing the app
      return null;
    }
  }

  Future createShopStats(var payload) async {
    try {
      var response = await dio.post("/shop-views/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      var data = response.data;
      return data;
    } on DioException catch (e) {
      throw Exception(e);
    }
  }
}
