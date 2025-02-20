import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  UserController userController = Get.find();
  Future getNotifications(page, limit) async {
    try {
      var response = await dio.get(
          "/notification/?page=$page&limit=$limit",
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

  // Future getSingleNotification(page, limit, keyword) async {
  //   try {
  //     var shopId = await SharedPreferencesUtil.getSelectedBusiness();
  //     if (shopId == null) {
  //       shopId = userController.user.value["Shops"][0]["id"];
  //       await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
  //     }
  //     var response = await dio.get(
  //         "/notifications/$shopId/?page=$page&limit=$limit",
  //         options: Options(headers: {
  //           "Authorization":
  //               "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
  //         }));

  //     var data = response.data["body"]["rows"];
  //     print(data);
  //     return data;
  //   } on DioException catch (e) {
  //     print(e.response);
  //   }
  // }

}