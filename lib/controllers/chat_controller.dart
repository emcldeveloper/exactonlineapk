import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  UserController userController = Get.find();
  Future getMyChats(page, limit, keyword) async {
    try {
      var response = await dio.get(
          "/chats/user/${userController.user.value["id"]}/?page=$page&limit=$limit&keyword=$keyword",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future getShopChats(page, limit, keyword) async {
    try {
      var shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
      var response = await dio.get(
          "/chats/shop/$shopId/?page=$page&limit=$limit&keyword=$keyword",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future getUserChats(page, limit, keyword) async {
    try {
      var userId = userController.user.value["id"];

      var response = await dio.get(
          "/chats/user/$userId/?page=$page&limit=$limit&keyword=$keyword",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future addChat(var payload) async {
    try {
      var response = await dio.post("/chats",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future editChat(id, payload) async {
    try {
      var response = await dio.patch("/chats/$id",
          data: payload ?? {},
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
