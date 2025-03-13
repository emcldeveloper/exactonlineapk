import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ShopProducts extends StatefulWidget {
  final String shopId;
  const ShopProducts({super.key, this.shopId = ""});

  @override
  State<ShopProducts> createState() => _ShopProductsState();
}

class _ShopProductsState extends State<ShopProducts> {
  final RxList products = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int currentPage = 1;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProducts(currentPage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts(int page) async {
    if (isLoadingMore.value || (!hasMore.value && page != 1)) return;
    if (page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    try {
      List<dynamic> res = await ProductController().getShopProducts(
          id: widget.shopId, page: page, limit: limit, keyword: "");
      final filteredRes = res.where((item) {
        // Explicitly check if ProductImages exists and is not empty
        final productImages = item["ProductImages"];
        return productImages != null && productImages.isNotEmpty;
      }).toList();

      if (filteredRes.isEmpty || filteredRes.length < limit) {
        hasMore.value = false;
      }
      if (page == 1) {
        products.value = filteredRes;
      } else {
        products.addAll(filteredRes);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Error loading products: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !isLoadingMore.value &&
        hasMore.value) {
      currentPage++;
      _fetchProducts(currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : products.isEmpty
              ? noData()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 500 ? 2 : 3;
                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: StaggeredGrid.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 10,
                          children: [
                            ...products.map((product) => ProductCard(
                                  data: product,
                                  isStagger: true,
                                )),
                            if (isLoadingMore.value) ...[
                              for (var i = 0; i < crossAxisCount; i++)
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(color: Colors.black),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
