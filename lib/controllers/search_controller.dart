// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  UserController userController = Get.find();
  Future getShopProducts({id, page, limit, keyword}) async {
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
        "/products/shop/$shopId/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));
    var data = response.data["body"]["rows"];
    return data;
  }

  Future<List> getProducts({page, limit, keyword, category}) async {
    // print(shopId);
    var response = await dio.get(
        "/products/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}&category=${category ?? "All"}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future getProduct({id}) async {
    // print(shopId);
    var response = await dio.get("/products/$id",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"];
    return data;
  }

  Future<List> getNewProducts({page, limit, keyword}) async {
    // print(shopId);
    var response = await dio.get(
        "/products/new/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    return data;
  }

  Future<List> getProductsForYou({page, limit, keyword}) async {
    // print(shopId);
    var response = await dio.get(
        "/products/for-you/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}",
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
      // ignore: avoid_print
      print("Error response");
      // ignore: avoid_print
      print(e.response);
      return e.response;
    }
  }
}
