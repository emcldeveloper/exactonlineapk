import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen for connectivity changes (handling list of results)
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool hasConnection = results.any((result) => result != ConnectivityResult.none);
      isConnected.value = hasConnection;

      if (!hasConnection) {
        Get.snackbar(
          "No Internet",
          "You are offline. Please check your connection.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  // Stream that continuously emits connection status
  Stream<bool> get connectionStream =>
      Connectivity().onConnectivityChanged.map((List<ConnectivityResult> results) {
        return results.any((result) => result != ConnectivityResult.none);
      });
}
