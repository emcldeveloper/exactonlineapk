import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForYouProducts extends StatefulWidget {
  const ForYouProducts({super.key});

  @override
  State<ForYouProducts> createState() => _ForYouProductsState();
}

class _ForYouProductsState extends State<ForYouProducts> {
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    ProductController()
        .getProductsForYou(page: 1, limit: 20, keyword: "")
        .then((res) {
      products.value =
          res.where((item) => item["ProductImages"].length > 0).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.value.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ProductCard(data: products.value[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
