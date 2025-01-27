import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ReelController extends GetxController {
  UserController userController = Get.find();
  Future getShopReels({page, limit, keyword}) async {
    try {
      var shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
      var response = await dio.get(
          "/reels/shop/$shopId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
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

  Future getReels({page, limit, keyword}) async {
    try {
      var response = await dio.get(
          "/reels/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));

      var data = response.data["body"]["rows"];
      print("get all reels");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  Future getSpecificReels({selectedId, page, limit, keyword}) async {
    try {
      var response = await dio.get(
          "/reels/$selectedId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  Future addReel(var payload) async {
    try {
      var response = await dio.post("/reels",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }
}
