import 'package:dio/dio.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/dio.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  UserController userController = Get.find();
  Future<List> getSubscriptions({page, limit, keyword, category}) async {
    var response = await dio.get(
        "/shops-subscriptions/?page=${page ?? 1}&limit=${limit ?? 10}&keyword=${keyword ?? ""}&category=${category ?? "All"}",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }));

    var data = response.data["body"]["rows"];
    print("subscriptions");
    print(data);
    return data;
  }
}
