// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  UserController userController = Get.find();
  Future getShopServices({id, page, limit, keyword}) async {
    var shopId;
    if (id == null) {
      shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }
    } else {
      shopId = id;
    }

    var response = await dio.get(
        "/services/shop/$shopId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    print("🆑🇮🇲");
    print(data);
    return data;
  }

  Future getSearchServices({keyword}) async {
    try {
      var response = await dio.get("/services/search/$keyword",
          options: Options(headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
          }));
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      // ignore: avoid_print
      print(e.response);
      return e.response;
    }
  }

  Future<List> getServices({page, limit, keyword, category}) async {
    // print(shopId);
    print(keyword);
    var response = await dio.get(
        "/services/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}&category=${category ?? "All"}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));
    var data = response.data["body"]["rows"];
    return data;
  }

  Future<List> getRelatedServices({serviceId, page, limit, keyword}) async {
    var response = await dio.get(
        "/services/related/service/$serviceId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));
    var data = response.data["body"]["rows"];
    print(data);
    return data;
  }

  Future getService({id}) async {
    // print(shopId);
    try {
      var response = await dio.get("/services/$id",
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

  Future<List> getNewServices({page, limit, keyword}) async {
    // print(shopId);
    var response = await dio.get(
        "/services/new/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future<List> getPopularServices({page, limit, keyword}) async {
    // print(shopId);
    var response = await dio.get(
        "/services/popular/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future<List> getServicesForYou({page, limit, keyword}) async {
    // print(shopId);
    var response = await dio.get(
        "/services/for-you/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future addService(var payload) async {
    try {
      var response = await dio.post("/services",
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

  Future editService(id, var payload) async {
    try {
      var response = await dio.patch("/services/$id",
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

  Future deleteService(id) async {
    try {
      var response = await dio.delete("/services/$id",
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

  Future addServiceStats(var payload) async {
    try {
      var response = await dio.post("/service-stats",
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
