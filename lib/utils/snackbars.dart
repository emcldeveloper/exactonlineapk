import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

void showErrorSnackbar({title, description}) {
  Get.snackbar(title ?? "", description ?? "",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      icon: const HugeIcon(icon: Icons.cancel, color: Colors.white));
}

void showSuccessSnackbar({title, description}) {
  Get.snackbar(title ?? "", description ?? "",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
}
