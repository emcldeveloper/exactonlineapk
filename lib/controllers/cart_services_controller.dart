import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class CartServicesController extends GetxController {
  Rx<List> servicesOnCart = Rx<List>([]);
  UserController userController = Get.find();

  Future addCartService(var payload) async {
    try {
      var response = await dio.post("/cart-products/services",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      print(e.response);
      throw e;
    }
  }

  Future getOnCartServices() async {
    try {
      print(
          "🔧 Getting cart services for user: ${userController.user.value["id"]}");
      var response = await dio.get(
          "/cart-products/services/user/${userController.user.value["id"]}",
          options: CacheOptions(
            store: MemCacheStore(),
            policy: CachePolicy.noCache, // Disable caching for this request
          ).toOptions().copyWith(
            headers: {
              "Authorization":
                  "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
            },
          ));
      var data = response.data["body"]["rows"];
      servicesOnCart.value = data;
      print("Cart services count: ${data.length}");
      return data;
    } on DioException catch (e) {
      print(e.response);
      return [];
    }
  }

  Future deleteCartService(String id) async {
    try {
      var response = await dio.delete("/cart-products/services/$id",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      return response.data;
    } on DioException catch (e) {
      print(e.response);
      throw e;
    }
  }
}
