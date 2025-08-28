import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class OrderedProductController extends GetxController {
  UserController userController = Get.find();

  Future addOrderedProduct(var payload) async {
    try {
      var response = await dio.post("/ordered-products",
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

  Future getUserOrderproducts(id) async {
    try {
      var response = await dio.get("/ordered-products/order/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future getShopOrderproducts(id) async {
    try {
      var shopId = await SharedPreferencesUtil.getCurrentShopId(
          userController.user.value["Shops"] ?? []);
      var response = await dio.get("/ordered-products/order/$id/$shopId",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future deleteOrderedProduct(id) async {
    try {
      var response = await dio.delete("/ordered-products/$id",
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
