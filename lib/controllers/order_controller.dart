import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  UserController userController = Get.find();
  Future getMyOrders(page, limit, keyword) async {
    try {
      var response = await dio.get(
          "/orders/user/${userController.user.value["id"]}/?page=$page&limit=$limit&keyword=$keyword",
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

  Future getShopOrders(page, limit, keyword) async {
    try {
      var shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
      var response = await dio.get(
          "/orders/shop/$shopId/?page=$page&limit=$limit&keyword=$keyword",
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

  Future addOrder(var payload) async {
    try {
      var response = await dio.post("/orders",
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

  Future editOrder(id, payload) async {
    try {
      var response = await dio.patch("/orders/$id",
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
