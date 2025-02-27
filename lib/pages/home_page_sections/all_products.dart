import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AllProducts extends StatelessWidget {
  AllProducts({super.key});

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
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4.8 / 5,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.black),
                    ),
                  );
                },
              )
            : GridView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length + (isLoading.value ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= products.length && isLoading.value) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(color: Colors.black),
                      ),
                    );
                  }
                  return ProductCard(data: products[index], height: 190);
                },
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
