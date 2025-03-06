import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

CartProductController cartProductController = Get.find();
Widget cartIcon() {
  return GestureDetector(
    onTap: () {
      Get.to(() => CartPage());
    },
    child: Obx(() => Badge(
          isLabelVisible: cartProductController.productsOnCart.value.length > 0,
          child: Icon(
            Bootstrap.cart,
            size: 20,
          ),
          backgroundColor: primary,
          label: Text(
              cartProductController.productsOnCart.value.length.toString()),
        )),
  );
}
