import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ServiceImageController extends GetxController {
  Future getServiceImages() async {
    var response = await dio.get("/service-images",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));
    var data = response.data["body"]["rows"];
    return data;
  }

  Future addServiceImage(var payload) async {
    try {
      var response = await dio.post("/service-images",
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
