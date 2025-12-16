import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class UsersControllers extends GetxController {
  var user;
  Future registerUser(payload) async {
    try {
      var response = await dio.post("/users", data: payload);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future inviteUser(payload) async {
    try {
      var response = await dio.post("/user-invitations",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      return response.data;
    } on DioException catch (e) {
      print("Error inviting user: $e");
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to send invitation');
    }
  }

  Future getShopUsers(String shopId) async {
    try {
      var response = await dio.get("/shops/$shopId/users",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      return response.data['body'] ?? [];
    } on DioException catch (e) {
      print("Error getting shop users: $e");
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to load shop users');
    }
  }

  Future removeShopUser(String shopId, String userId) async {
    try {
      var response = await dio.delete("/shops/$shopId/users/$userId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          }));
      return response.data;
    } on DioException catch (e) {
      print("Error removing shop user: $e");
      throw Exception(e.response?.data?['message'] ?? 'Failed to remove user');
    }
  }
}
