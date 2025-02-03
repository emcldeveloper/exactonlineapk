import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ShopController extends GetxController {
  Future loadUserShops(id) async {
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
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      print("Error creating shop account: ${e.response}");
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
      print("Error creating shop account: ${e.response}");
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
      print("Error sending documents: ${e.response}");
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
      print(id);
      var response = await dio.get("/shops/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"];
      print("Getting shop details");
      print(data);
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error loading shop details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      print("Error loading shop details: ${e.response}");
      throw Exception(e);
    }
  }

  Future updateShopData(id, payload) async {
    try {
      print("payload");
      print(id);
      print(payload);
      var response = await dio.patch("/shops/$id",
          data: payload,
          options: Options(
            headers: {
              "Authorization":
                  "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
            },
          ));
      var data = response.data;
      print("Updating shop details");
      print(data);
      Get.snackbar("Success", "Shop updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error updating shop details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01, color: Colors.white));
      print("Error updating shop details: ${e.response}");
    }
  }

  Future deleteShop(id) async {
    try {
      print("starting deleting");
      var response = await dio.get("/shops/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data;
      print("Shop deleted successfully: $data");
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
      print("Error creating shop account: ${e.response}");
      throw Exception(e);
    }
  }

  Future createShopCalendar(var payload) async {
    try {
      print("payload");
      print(payload);
      var response = await dio.post(
        "/shop-calenders/",
        data: payload,
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
        }),
      );
      var data = response.data;
      print("Shop-Calendar created successfully: $data");
      Get.snackbar("Success", "Shop-Calendar created successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
      return data;
    } on DioException catch (e) {
      // Show a Snackbar with the error
      Get.snackbar("Error", "Error creating Shop-Calendar",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      print("Error creating Shop-Calendar: ${e.response}");
      // Do not re-throw the exception to avoid crashing the app
      return null;
    }
  }

  Future createShopStats(var payload) async {
    try {
      print("payload on stats");
      print(payload);
      var response = await dio.post("/shop-views/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      var data = response.data;
      print("shop-stats being sent");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error sending shop-stats account: ${e.response}");
      throw Exception(e);
    }
  }
}
