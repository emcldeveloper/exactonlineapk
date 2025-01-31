import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class FollowingController extends GetxController {
  UserController userController = Get.find();

  Future followShop(var payload) async {
    try {
      var response = await dio.post("/shop-followers/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      print(data);
      Get.snackbar("Success", "Successfully Followed Shop",
          backgroundColor: Colors.green, colorText: Colors.white);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      Get.snackbar("Error", "Failed to follow shop",
          backgroundColor: Colors.red, colorText: Colors.white);
      return e.response;
    }
  }

  Future getShopsFollowing({page, limit, keyword}) async {
    try {
      var userId = userController.user.value['id'] ?? "";
      var response = await dio.get(
          "/shops/following/user/$userId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  Future getFollowers({page, limit, keyword}) async {
    try {
      var response = await dio.get(
          "/shop-followers/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print("get all shop-followers");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  Future deleteFollowing(id) async {
    try {
      print("starting deleting");
      var response = await dio.get("/shop-followers/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data;
      print("Unfollowed successfully: $data");
      Get.snackbar("Success", "Shop Unfollowed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
      return data;
    } on DioException catch (e) {
      Get.snackbar("Error", "Error unfollowing shop account",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      print("Error Unfollowing shop account: ${e.response}");
      throw Exception(e);
    }
  }
}
