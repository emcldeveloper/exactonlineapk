import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  Future registerUser(Map<String, dynamic> payload) async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/",
        data: payload,
      );
      var data = response.data["body"]["message"];
      return data;
  } on DioException catch (e) {
      print("Error fetching user details: ${e.response}");
      throw Exception(e);
    }
  }

  Future verifyUserCode(Map<String, dynamic> payload) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/auth/verify-code",
        data: payload,
      );
      var data = response.data;
      return data;
  } on DioException catch (e) {
      print("Error fetching user details: ${e.response}");
      throw Exception(e);
    }
  }

  Future sendUserCode(Map<String, dynamic> payload) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      var response = await dio.post(
        "/users/auth/send-code",
        data: payload,
      );
      var data = response.data;
      return data;
    } on DioException catch (e) {
      print("Error fetching user details: ${e.response}");
      throw Exception(e);
    }
  }
}
