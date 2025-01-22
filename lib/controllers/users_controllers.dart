import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class UsersControllers extends GetxController {
  var user;
  Future registerUser(payload) async {
    try {
      var response = await dio.post("/users", data: payload);
      return response;
    } catch (e) {
      print(e);
    }
  }
}
