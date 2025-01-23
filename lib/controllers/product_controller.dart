import 'package:dio/dio.dart';
import 'package:e_online/controllers/auth_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  UserController userController = Get.find();
  Future getShopProducts({page, limit, keyword}) async {
    var shopId = await SharedPreferencesUtil.getSelectedBusiness();
    if (shopId == null) {
      shopId = userController.user["Shops"][0]["id"];
      await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
    }
    // print(shopId);
    var response = await dio.get(
        "/products/shop/$shopId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future addProduct(var payload) async {
    try {
      var response = await dio.post("/products",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];

      return data;
    } on DioException catch (e) {
      print("Error response");
      print(e.response);
      return e.response;
    }
  }
}
