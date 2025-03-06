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
    if (page > 1 && (_isLoadingMore || !_hasMore)) return;

    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final res = await ProductController().getShopProducts(
        page: page,
        limit: _limit,
      );

      if (res.isEmpty || res.length < _limit) {
        _hasMore = false;
      }

      setState(() {
        if (page == 1) {
          products = res;
        } else {
          products = [...products, ...res];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
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

  void onDelete() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      products = [];
      _fetchProducts(_currentPage);
    });
  }

  @override
  void dispose() {
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
                ? noData()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: products.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length && _isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                      return products[index]['ProductImages'].length > 0
                          ? ShopProductCard(
                              data: products[index],
                              onDelete: onDelete,
                            )
                          : Container();
                    },
                  ),
      ),
    );
  }
}
