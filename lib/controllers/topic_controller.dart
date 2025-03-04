import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class TopicController extends GetxController {
  UserController userController = Get.find();

  Future getChatTopics(chatId, page, limit, keyword) async {
    try {
      var response = await dio.get(
          "/topics/chat/$chatId/?page=$page&limit=$limit&keyword=$keyword",
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

  Future getTopic({id}) async {
    try {
      var response = await dio.get("/topics/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future addTopic(var payload) async {
    try {
      var response = await dio.post("/topics",
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

  Future editTopic(id, payload) async {
    try {
      var response = await dio.patch("/topics/$id",
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
