import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  UserController userController = Get.find();
  var favorites = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    isLoading.value = true;
    try {
      var userId = userController.user.value['id'] ?? "";
      var response = await dio.get(
          "/favorites/user/$userId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      favorites.value = List<Map<String, dynamic>>.from(response.data["body"]["rows"]);
    } catch (e) {
      print("Error fetching favorites: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFavorite(var payload) async {
    try {
      var response = await dio.post("/favorites",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      
      favorites.add(response.data["body"]); 
      Get.snackbar("Success", "Favorite added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to add favorite",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> deleteFavorite(String id) async {
    try {
      await dio.delete("/favorites/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      favorites.removeWhere((item) => item['id'] == id);
      Get.snackbar("Success", "Favorite removed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to remove favorite",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
