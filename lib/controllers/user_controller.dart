import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class UserController extends GetxController {
  var user;
  Future getUserDetails() async {
    try {
      var response = await dio.get(
        "/users/me",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data;
      return data;
    } catch (e) {
      Get.snackbar("Error", "Error fetching user details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
      print("Error fetching user details: $e");
    }
  }

  Future getOneUserData(var payload) async {
    // String? token = await SharedPreferencesUtil.getAccessToken();
    // if (token == null) {
    //   throw Exception("Access token is null");
    // }
    var response = await dio.get("/users/${payload.id}",
        options: Options(headers: {
          "Authorization": "Bearer ${SharedPreferencesUtil.getAccessToken()}"
        }));
    // options: Options(headers: {"Authorization": "Bearer $token"}),
    var data = response.data;
    print(data);
    return data;
  }

  Future updateUserData(id, payload) async {
    try {
      var response = await dio.patch("/users/$id",
          data: payload,
          options: Options(headers: {
            "Authorization": "Bearer ${SharedPreferencesUtil.getAccessToken()}",
          }));
      var data = response.data;
      return data;
    } catch (e) {
      Get.snackbar("Error", "Error updating user details",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedRssError, color: Colors.white));
      print("Error fetching user details: $e");
    }
  }
}
