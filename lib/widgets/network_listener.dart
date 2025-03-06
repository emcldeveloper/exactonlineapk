import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/controllers/network_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkListener extends StatelessWidget {
  final NetworkController networkController = Get.put(NetworkController());

  void _retryConnection() async {
    await Future.delayed(Duration(milliseconds: 500));

    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;

    networkController.isConnected.value = hasConnection;

    if (hasConnection) {
      Get.offAll(() => WayPage());
    } else {
      Get.snackbar(
        "No Internet",
        "Still no connection. Please try again later.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return networkController.isConnected.value
          ? SizedBox.shrink()
          : Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        spacer1(),
                        Image.asset(
                          'assets/images/closeicon.jpg',
                          height: 100,
                        ),
                        spacer1(),
                        HeadingText('No Internet Connection'),
                        spacer(),
                        ParagraphText(
                          'Please, Connect to the internet before using the App again',
                          textAlign: TextAlign.center,
                          color: mutedTextColor,
                        ),
                        spacer3(),
                        customButton(
                          onTap: _retryConnection,
                          text: "Try Again",
                          rounded: 15.0,
                        ),
                        spacer1(),
                      ],
                    ),
                  ),
                ),
              ),
            );
    });
  }
}
