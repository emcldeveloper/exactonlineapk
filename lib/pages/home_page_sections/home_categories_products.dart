import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/no_data.dart';
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
  var loading = true.obs;
  @override
  void initState() {
    ProductController()
        .getProducts(page: 1, limit: 20, keyword: "", category: widget.category)
        .then((res) {
      products.value =
          res.where((item) => item["ProductImages"].length > 0).toList();
      loading.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => loading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : products.value.isEmpty
              ? noData()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 2.0,
                      childAspectRatio: 0.60,
                    ),
                    itemCount: products.value.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                          data: products.value[index], height: 190);
                    },
                  ),
                ),
    );
  }
}
