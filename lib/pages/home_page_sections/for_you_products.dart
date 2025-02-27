import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForYouProducts extends StatelessWidget {
  ForYouProducts({super.key});

  final RxList products = <dynamic>[].obs;
  final ScrollController _scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  final int _limit = 5;

  @override
  Widget build(BuildContext context) {
    _fetchProducts(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 235,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemCount: products.length + (isLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length && isLoading.value) {
                return products.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 110.0),
                        child: SizedBox(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ProductCard(data: products[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _fetchProducts(int page) async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    try {
      final res = await ProductController().getProductsForYou(
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
        products.value = filteredRes; // Replace the list
      } else {
        products.addAll(filteredRes); // Append new items
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
