import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    ProductController()
        .getProducts(page: 1, limit: 20, keyword: "")
        .then((res) {
      products.value =
          res.where((item) => item["ProductImages"].length > 0).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => products.value.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4.5 / 5,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    child: Shimmer.fromColors(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      enabled: true,
                    ),
                  );
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 0.60,
                ),
                itemCount: products.value.length,
                itemBuilder: (context, index) {
                  return ProductCard(data: products.value[index], height: 190);
                },
              ),
            ),
    );
  }
}
