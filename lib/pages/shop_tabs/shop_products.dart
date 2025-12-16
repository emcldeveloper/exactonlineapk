import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../widgets/shop_product_card.dart';

class ShopProducts extends StatefulWidget {
  const ShopProducts({super.key});

  @override
  State<ShopProducts> createState() => _ShopProductsState();
}

class _ShopProductsState extends State<ShopProducts> {
  final ScrollController _scrollController = ScrollController();
  List products = [];
  int _currentPage = 1;
  final int _limit = 6;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchProducts(int page) async {
    // Prevent duplicate requests
    if (page > 1 && (_isLoadingMore || !_hasMore)) return;

    // Set loading states
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _hasMore = true; // Reset hasMore when refreshing
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      print('📄 Fetching page $page with limit $_limit');

      final res = await ProductController().getShopProducts(
        page: page,
        limit: _limit,
      );

      print('📦 Received ${res?.length ?? 0} products for page $page');

      // Check if we have more pages
      if (res == null || res.isEmpty || res.length < _limit) {
        _hasMore = false;
        print('🚫 No more pages available');
      }

      setState(() {
        if (page == 1) {
          products = res ?? [];
        } else {
          products = [...products, ...(res ?? [])];
        }
      });

      print('📊 Total products now: ${products.length}');
    } catch (e) {
      print('❌ Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Reset hasMore on error to allow retry
      if (page > 1) {
        _currentPage--; // Revert page increment on error
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    // Check if user has scrolled to 80% of the content
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      print('🔄 Triggering pagination - Loading page ${_currentPage + 1}');
      _currentPage++;
      _fetchProducts(_currentPage);
    }
  }

  void onDelete() {
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    print('🔄 Refreshing products...');
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      products = [];
    });
    await _fetchProducts(_currentPage);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : products.isEmpty
                ? RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: noData(),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: products.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == products.length && _isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        return ShopProductCard(
                          data: products[index],
                          onDelete: onDelete,
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
