import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  UserController userController = Get.find();
  var favorites = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites({page = 1, limit = 10}) async {
    try {
      var userId = userController.user.value['id'] ?? "";
      var response =
          await dio.get("/favorites/user/$userId?limit=$limit&page=$page",
              options: CacheOptions(
                store: MemCacheStore(),
                policy: CachePolicy.noCache, // Disable caching for this request
              ).toOptions().copyWith(
                headers: {
                  "Authorization":
                      "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
                },
              ));

      var data = List<Map<String, dynamic>>.from(response.data["body"]["rows"]);
      print(data);

      // Handle pagination properly
      if (page == 1) {
        favorites.value = data; // Replace for first page
      } else {
        favorites.addAll(data); // Append for subsequent pages
      }
    } on DioException catch (e) {
      print("Error fetching favorites: ${e.response}");
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
          backgroundColor: Colors.green, colorText: Colors.white);
    } on DioException catch (e) {
      print("Error adding favorite: ${e.response}");
      Get.snackbar("Error", "Failed to add favorite",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteFavorite(String id) async {
    try {
      print("id of the deleted favorite item");
      print(id);
      await dio.delete("/favorites/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      favorites.removeWhere((item) => item['id'] == id);
      Get.snackbar("Success", "Favorite removed successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on DioException catch (e) {
      print("Error deleting favorite: ${e.response}");
      Get.snackbar("Error", "Failed to remove favorite",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
