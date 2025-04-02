import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class CartProductController extends GetxController {
  Rx<List> productsOnCart = Rx<List>([]);
  UserController userController = Get.find();

  Future addCartProduct(var payload) async {
    try {
      var response = await dio.post("/cart-products",
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

  Future getOnCartproducts() async {
    try {
      print("🆑");
      print(userController.user.value["id"]);
      var response = await dio.get(
          "/cart-products/user/${userController.user.value["id"]}",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
      productsOnCart.value = data;
      print(data.length);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future getUserOrderproducts(id) async {
    try {
      var response = await dio.get("/cart-products/order/$id",
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
      var shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
      var response = await dio.get("/cart-products/order/$id/$shopId",
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

  Future deleteCartProduct(id) async {
    try {
      var response = await dio.delete("/cart-products/$id",
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

  @override
  void onInit() {
    getOnCartproducts();
    super.onInit();
  }
}
