import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewArrivalProducts extends StatefulWidget {
  const NewArrivalProducts({super.key});

  @override
  State<NewArrivalProducts> createState() => _NewArrivalProductsState();
}

class _NewArrivalProductsState extends State<NewArrivalProducts> {
  Rx<List> products = Rx<List>([]);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 5;
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
      final res = await ProductController().getNewProducts(
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
      // Handle error (e.g., show a snackbar)
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
        child: SizedBox(
          height: 235,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _scrollController, // Attach ScrollController
            itemCount: products.value.length +
                (_isLoading ? 1 : 0), // Add loading indicator
            itemBuilder: (context, index) {
              if (index == products.value.length && _isLoading) {
                return products.value.length > 0
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
                child: ProductCard(data: products.value[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
