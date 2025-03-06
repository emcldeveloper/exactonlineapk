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
    return Obx(() => loading.value
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : products.value.isEmpty
            ? noData()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Expanded(
                      // Ensure it takes available space
                      child: GridView.builder(
                        physics:
                            const BouncingScrollPhysics(), // Allow scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth < 500 ? 2 : 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.value.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            data: products.value[index],
                            height: 190,
                          );
                        },
                      ),
                    );
                  },
                ),
              ));
  }
}
