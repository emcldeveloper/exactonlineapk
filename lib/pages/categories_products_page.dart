import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesProductsPage extends StatefulWidget {
  final dynamic category;

  const CategoriesProductsPage({super.key, required this.category});

  @override
  State<CategoriesProductsPage> createState() => _CategoriesProductsPageState();
}

class _CategoriesProductsPageState extends State<CategoriesProductsPage> {
  bool loading = true;
  List products = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10; // Kept at 10 as per original code
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedSubcategoryId = '';

  @override
  void initState() {
    super.initState();
    trackScreenView("CategoriesProductsPage");
    _fetchProducts(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _fetchProducts(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore)) return; // Prevent overlap
    if (page == 1) {
      setState(() => loading = true); // Only show initial loading for first
    }
    if (page > 1) setState(() => _isLoadingMore = true);

    try {
      final targetId = _selectedSubcategoryId.isNotEmpty
          ? _selectedSubcategoryId
          : widget.category["id"];
      final res = await ProductController().getProducts(
        page: page,
        limit: _limit,
        keyword: "",
        category: targetId,
      );

      final filteredRes = res; // Server handles filtering

      setState(() {
        if (filteredRes.isEmpty || filteredRes.length < _limit) {
          _hasMore = false; // No more data to fetch
        }

        if (page == 1) {
          products = filteredRes; // Replace for first page
        } else {
          products = [
            ...products,
            ...filteredRes,
          ]; // Append for subsequent pages
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      if (page == 1) setState(() => loading = false);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.category["Subcategories"] as List?)?.isNotEmpty == true)
              SizedBox(
                height: 55,
                child: Builder(builder: (context) {
                  final subs = (widget.category["Subcategories"] as List)
                      .cast<Map<String, dynamic>>();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subs.length + 1,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedSubcategoryId.isEmpty;
                        return ChoiceChip(
                          label: const Text('All'),
                          selected: isSelected,
                          backgroundColor: primaryColor,
                          selectedColor: primary,
                          labelStyle: TextStyle(
                            color: isSelected ? mainColor : mutedTextColor,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? primary
                                : mutedTextColor.withOpacity(0.2),
                          ),
                          showCheckmark: false,
                          onSelected: (val) {
                            if (!isSelected) {
                              setState(() {
                                _selectedSubcategoryId = '';
                                _currentPage = 1;
                                _hasMore = true;
                                products = [];
                              });
                              _fetchProducts(_currentPage);
                            }
                          },
                        );
                      }
                      final sub = subs[index - 1];
                      final isSelected = _selectedSubcategoryId == sub["id"];
                      return ChoiceChip(
                        label: Text(
                            "${sub["name"]} (${sub["productsCount"] ?? 0})"),
                        selected: isSelected,
                        backgroundColor: primaryColor,
                        selectedColor: primary,
                        labelStyle: TextStyle(
                          color: isSelected ? mainColor : mutedTextColor,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? primary
                              : mutedTextColor.withOpacity(0.2),
                        ),
                        showCheckmark: false,
                        onSelected: (val) {
                          final newId = val ? sub["id"] : '';
                          if (_selectedSubcategoryId != newId) {
                            setState(() {
                              _selectedSubcategoryId = newId;
                              _currentPage = 1;
                              _hasMore = true;
                              products = [];
                            });
                            _fetchProducts(_currentPage);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            Expanded(
              child: Builder(builder: (context) {
                if (loading && _currentPage == 1) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                }
                if (products.isEmpty) {
                  return Center(child: noData());
                }
                return MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length + (_isLoadingMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      final product = products[index];
                      return ProductCard(
                        isStagger: true,
                        data: product,
                      );
                    }
                    // Loading placeholders when fetching more
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(height: 180, color: Colors.black),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
