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
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
      var response = await dio.get(
          "/reels/shop/$shopId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
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
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  Future getSpecificReels({selectedId, page, limit, keyword}) async {
    try {
      var response = await dio.get("/reels/shop/$selectedId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
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

  Future addReelStats(var payload) async {
    try {
      print("reel stats payload");
      print(payload);
      var response = await dio.post("/reel-stats",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      print("response");
      print(response);
      var data = response.data["body"];
      print("sending reel stats");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }

  // Future getReelStats() async {
  //   try {
  //     var response = await dio.get("/reel-stats",
  //         options: Options(headers: {
  //           "Authorization":
  //               "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
  //         }));
  //     var data = response.data["body"];
  //     print("getting reel stats");
  //     print(data);
  //     return data;
  //   } on DioException catch (e) {
  //     print("Error response");
  //     print(e.response);
  //     return e.response;
  //   }
  // }

  Future deleteReelStats(id) async {
    try {
      print(id);
      print("deleting reel like been called");
      var response = await dio.delete("/reel-stats/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      print("deleting reel like");
      print(data);
      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }
}
