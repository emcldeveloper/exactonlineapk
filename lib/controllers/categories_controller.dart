import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  Future getCategories({page, limit, keyword}) async {
    try {
      var response = await dio.get(
          "/categories/?page=$page&limit=$limit&keyword=$keyword",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"]["rows"];
      return data;
    } on DioException catch (e) {
      return e.response;
    }
  }
}
