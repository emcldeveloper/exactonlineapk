import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  UserController userController = Get.find();
  Future<List<Map<String, dynamic>>> getSubscriptions(
      {page, limit, keyword}) async {
    try {
      var response = await dio.get(
          "/subscriptions/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response.data["body"]["rows"]);
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      Get.snackbar("Error", "Failed to get subscriptions",
          backgroundColor: Colors.red, colorText: Colors.white);
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> Subscribing(var payload) async {
    try {
      print("subscriptions started");
      print(payload);
      var response = await dio.post("/shops-subscriptions/",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      print("subscribing already called");
      print(response);
      var data = Map<String, dynamic>.from(response.data["body"]);
      print("subscribing response");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      Get.snackbar("Error", "Failed to subscribing shop",
          backgroundColor: Colors.red, colorText: Colors.white);
      throw Exception(e);
    }
  }
}
