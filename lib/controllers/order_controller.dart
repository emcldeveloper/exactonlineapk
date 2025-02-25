import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  UserController userController = Get.find();

  RxList<dynamic> myOrders = <dynamic>[].obs;
  RxList<dynamic> shopOrders = <dynamic>[].obs;

  RxBool isLoading = false.obs;
  int currentPage = 1;
  int shopCurrentPage = 1;
  final int limit = 10;
  final int totalPages = 10;
  
  var orders = <dynamic>[].obs; // Stores the list of orders
  var hasMore = true.obs; // Indicates if more data is available

  @override
  void onInit() {
    super.onInit();
    getMyOrders(); // Load initial orders
  }

  Future<void> getMyOrders({bool isRefresh = false}) async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        currentPage = 1;
        hasMore.value = true;
      }

      var response = await dio.get(
        "/orders/user/${userController.user.value["id"]}/?page=$currentPage&limit=$limit",
        options: Options(headers: {
          "Authorization": "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );

      var data = response.data["body"]["rows"];

      if (isRefresh) {
        orders.value = data; // Replace data if refreshed
      } else {
        orders.addAll(data); // Append new data
      }

      if (data.length < limit) {
        hasMore.value = false; // No more data to load
      } else {
        currentPage++; // Increment page for next request
      }
    } on DioException catch (e) {
      print(e.response);
    } finally {
      isLoading.value = false;
    }
  }

  // Future getMyOrders(page, limit, keyword) async {
  //   try {
  //     var response = await dio.get(
  //         "/orders/user/${userController.user.value["id"]}/?page=$page&limit=$limit&keyword=$keyword",
  //         options: Options(headers: {
  //           "Authorization":
  //               "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
  //         }));

  //     var data = response.data["body"]["rows"];
  //     print(data);
  //     return data;
  //   } on DioException catch (e) {
  //     print(e.response);
  //   }
  // }
Future<void> getShopOrders({bool isLoadMore = false}) async {
    if (isLoading.value || (shopCurrentPage > totalPages)) return;

    try {
      isLoading.value = true;

      var shopId = await SharedPreferencesUtil.getSelectedBusiness();
      if (shopId == null) {
        shopId = userController.user.value["Shops"][0]["id"];
        await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
      }

      var response = await dio.get(
        "/orders/shop/$shopId/?page=$shopCurrentPage&limit=$limit",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );

      var data = response.data["body"]["rows"];
      if (isLoadMore) {
        shopOrders.addAll(data);
      } else {
        shopOrders.assignAll(data);
      }

      shopCurrentPage++;
    } on DioException catch (e) {
      print(e.response);
    } finally {
      isLoading.value = false;
    }
  }

  // Future getShopOrders(page, limit, keyword) async {
  //   try {
  //     var shopId = await SharedPreferencesUtil.getSelectedBusiness();
  //     if (shopId == null) {
  //       shopId = userController.user.value["Shops"][0]["id"];
  //       await SharedPreferencesUtil.saveSelectedBusiness(shopId!);
  //     }
  //     var response = await dio.get(
  //         "/orders/shop/$shopId/?page=$page&limit=$limit&keyword=$keyword",
  //         options: Options(headers: {
  //           "Authorization":
  //               "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
  //         }));

  //     var data = response.data["body"]["rows"];
  //     print(data);
  //     return data;
  //   } on DioException catch (e) {
  //     print(e.response);
  //   }
  // }

  Future getOrder({id}) async {
    try {
      var response = await dio.get("/orders/$id",
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

  Future addOrder(var payload) async {
    try {
      var response = await dio.post("/orders",
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

  Future editOrder(id, payload) async {
    try {
      var response = await dio.patch("/orders/$id",
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
