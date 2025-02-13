import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  Future getMyReview(id) async {
    try {
      var response = await dio.get("/product-reviews/$id",
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

  Future getReviews(page, limit, keyword) async {
    try {
      var response = await dio.get(
          "/product-reviews/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=$keyword",
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

  Future addReview(var payload) async {
    try {
      var response = await dio.post("/product-reviews",
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

  Future editReview(id, payload) async {
    try {
      var response = await dio.patch("/product-reviews/$id",
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
