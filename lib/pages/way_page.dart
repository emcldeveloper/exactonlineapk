import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/auth/login_page.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WayPage extends StatelessWidget {
  WayPage({super.key});
  final UserController userController = Get.put(UserController());

  Future<bool> _checkTokenAndFetchUserDetails() async {
    String? token = await SharedPreferencesUtil.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        var response = await userController.getUserDetails();
        var userDetails = response["body"];
        print(userDetails);
        userController.user = userDetails;
        return true;
      } catch (e) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkTokenAndFetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          );
        }
        var result = snapshot.requireData;
        if (snapshot.hasData && result == true) {
          return const MainPage();
        }

        return LoginPage();
      },
    );
  }
}
