import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ProductColorController extends GetxController {
  Future getProductColors() async {
    var response = await dio.get("/product-colors",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));
    var data = response.data["body"]["rows"];
    return data;
  }

  Future addProductColor(var payload) async {
    try {
      var response = await dio.post("/product-colors",
          data: payload,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      return e.response;
    }
  }
}
