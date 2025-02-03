import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

OrderedProductController orderedProductController = Get.find();
Widget cartIcon() {
  return GestureDetector(
    onTap: () {
      Get.to(() => CartPage());
    },
    child: Obx(() => Badge(
          isLabelVisible:
              orderedProductController.productsOnCart.value.length > 0,
          child: Icon(
            Bootstrap.cart,
            size: 20,
          ),
          label: Text(
              orderedProductController.productsOnCart.value.length.toString()),
        )),
  );
}
