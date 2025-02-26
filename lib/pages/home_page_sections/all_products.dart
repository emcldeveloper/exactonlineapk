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
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 50; // Kept at 20 as per original code
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _fetchProducts(int page) async {
    if (_isLoading || !_hasMore)
      return; // Prevent multiple simultaneous fetches
    setState(() => _isLoading = true);

    try {
      final res = await ProductController().getProducts(
        page: page,
        limit: _limit,
        keyword: "",
      );
      final filteredRes =
          res.where((item) => item["ProductImages"].length > 0).toList();

      if (filteredRes.isEmpty || filteredRes.length < _limit) {
        _hasMore = false; // No more data to fetch
      }

      if (page == 1) {
        products.value = filteredRes; // Replace for first page
      } else {
        products.value = [
          ...products.value,
          ...filteredRes
        ]; // Append for subsequent pages
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _currentPage++;
      _fetchProducts(_currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: products.value.isEmpty && !_isLoading
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
                  return Container(
                    child: Shimmer.fromColors(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(color: Colors.black),
                      ),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      enabled: true,
                    ),
                  );
                },
              )
            : GridView.builder(
                controller: _scrollController, // Attach ScrollController
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.value.length +
                    (_isLoading ? 2 : 0), // Add loading items
                itemBuilder: (context, index) {
                  if (index >= products.value.length && _isLoading) {
                    // Loading placeholders for grid (2 items for crossAxisCount: 2)
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Shimmer.fromColors(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(color: Colors.black),
                        ),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        enabled: true,
                      ),
                    );
                  }
                  return ProductCard(data: products.value[index], height: 190);
                },
              ),
      ),
    );
  }
}
