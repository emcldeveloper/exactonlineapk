import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class CategoriesProductsPage extends StatefulWidget {
  final dynamic category;

  const CategoriesProductsPage({super.key, required this.category});

  @override
  State<CategoriesProductsPage> createState() => _CategoriesProductsPageState();
}

class _CategoriesProductsPageState extends State<CategoriesProductsPage> {
  var loading = true.obs;
  Rx<List> products = Rx<List>([]);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10; // Kept at 10 as per original code
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    trackScreenView("CategoriesProductsPage"); 
    _fetchProducts(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _fetchProducts(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore))
      return; // Prevent overlap for subsequent pages
    if (page == 1)
      loading.value = true; // Only show initial loading for first page
    if (page > 1) setState(() => _isLoadingMore = true);

    try {
      final res = await ProductController().getProducts(
        page: page,
        limit: _limit,
        keyword: "",
        category: widget.category["id"],
      );

      final filteredRes =
          res; // Assuming filtering is done server-side or not needed here

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
      if (page == 1) loading.value = false;
      if (page > 1) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
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
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 14.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: HeadingText(widget.category["name"]),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: GetX<ProductController>(
        init: ProductController(),
        builder: (controller) {
          return loading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                )
              : products.value.isEmpty
                  ? noData()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        controller:
                            _scrollController, // Attach ScrollController
                        itemCount: products.value.length +
                            (_isLoadingMore ? 1 : 0), // Add loading item
                        itemBuilder: (context, index) {
                          if (index == products.value.length &&
                              _isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                          return FavoriteCard(data: products.value[index]);
                        },
                      ),
                    );
        },
      ),
    );
  }
}
