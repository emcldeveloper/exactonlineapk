import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AllProducts extends StatelessWidget {
  AllProducts({super.key,});

  final RxList products = <dynamic>[].obs;
  final ScrollController _scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  final int _limit = 50;

  @override
  Widget build(BuildContext context) {
    _fetchProducts(_currentPage);
    _scrollController.addListener(_onScroll);

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: products.isEmpty && !isLoading.value
            ? StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(5, (index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.black),
                    ),
                  );
                }),
              )
            : StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 10,
                children: [
                  ...products
                      .map((product) => ProductCard(
                            isStagger: true,
                            data: product,
                          ))
                      .toList(),
                  if (isLoading.value) ...[
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(color: Colors.black),
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ]
                ],
              ),
      ),
    );
  }

  Future<void> _fetchProducts(int page) async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    try {
      final res = await ProductController().getProducts(
        page: page,
        limit: _limit,
        keyword: "",
      );
      final filteredRes =
          res.where((item) => item["ProductImages"].isNotEmpty).toList();

      if (filteredRes.isEmpty || filteredRes.length < _limit) {
        hasMore.value = false;
      }

      if (page == 1) {
        products.value = filteredRes;
      } else {
        products.addAll(filteredRes);
      }
    } catch (e) {
      Get.snackbar("Error", "Error loading products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !isLoading.value &&
        hasMore.value) {
      _currentPage++;
      _fetchProducts(_currentPage);
    }
  }
}
