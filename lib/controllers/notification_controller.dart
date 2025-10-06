// ignore_for_file: unused_import, unused_catch_clause

import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  var unreadCount = 0.obs;

  Future getNotifications(page, limit) async {
    try {
      var response = await dio.get(
        "/notifications/?page=$page&limit=$limit",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"]["rows"];
      return data;
      // ignore: empty_catches
    } on DioException catch (e) {}
  }

  Future<int> getUnreadCount() async {
    try {
      var response = await dio.get(
        "/notifications/unread",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      int count = response.data["body"] ?? 0;
      unreadCount.value = count;
      return count;
    } on DioException catch (e) {
      return 0;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await dio.patch(
        "/notifications/unread",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      unreadCount.value = 0;
    } on DioException catch (e) {
      // Handle error
    }
  }
}
