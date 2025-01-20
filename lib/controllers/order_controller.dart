import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  Future getMyOrders() async {
    var response = await dio.get("/orders/me",
        options:
            Options(headers: {"Authorization": "Bearer ${SharedPreferencesUtil.getAccessToken()}"}));

    var data = response.data["body"]["rows"];
    print(data);
    return data;
  }

  Future addOrder(var payload) async {
    
    var response = await dio.post("/orders",
        data: payload,
        options:
            Options(headers: {"Authorization": "Bearer ${SharedPreferencesUtil.getAccessToken()}"}));
    var data = response.data["body"];
    return data;
  }
}