import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllNewArrivalProducts extends StatefulWidget {
  const AllNewArrivalProducts({super.key});

  @override
  State<AllNewArrivalProducts> createState() => _AllNewArrivalProductsState();
}

class _AllNewArrivalProductsState extends State<AllNewArrivalProducts> {
  Rx<List> products = Rx<List>([]);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10; // Kept at 20 as per original code
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
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: HeadingText("New Arrival"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: Obx(
        () => products.value.isEmpty && !_isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  controller: _scrollController, // Attach ScrollController
                  itemCount: products.value.length +
                      (_isLoading ? 1 : 0), // Add loading item
                  itemBuilder: (context, index) {
                    if (index == products.value.length && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FavoriteCard(data: products.value[index]),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
