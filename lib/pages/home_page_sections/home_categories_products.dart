import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomeCategoriesProducts extends StatefulWidget {
  var category;
  HomeCategoriesProducts({super.key, this.category});

  @override
  State<HomeCategoriesProducts> createState() => _HomeCategoriesProductsState();
}

class _HomeCategoriesProductsState extends State<HomeCategoriesProducts> {
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    // ProductController()
    //     .getProducts(page: 1, limit: 20, keyword: "", category: widget.category)
    //     .then((res) {
    //   products.value =
    //       res.where((item) => item["ProductImages"].length > 0).toList();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => products.value.length < 1
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16,
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
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.value.length,
                itemBuilder: (context, index) {
                  return ProductCard(data: products.value[index], height: 170);
                },
              ),
            ),
    );
  }
}
