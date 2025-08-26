import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final FavoriteController favoriteController = Get.put(FavoriteController());
  var isLoading = false.obs;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10; // Assuming a reasonable limit; adjust as needed
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    trackScreenView("FavouritesPage");
    // Reset pagination state
    _currentPage = 1;
    _hasMore = true;
    _getFavoritesData(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _getFavoritesData(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore))
      return; // Prevent overlap for subsequent pages
    if (page == 1)
      isLoading.value = true; // Show initial loading for first page
    if (page > 1) setState(() => _isLoadingMore = true);

    try {
      // Get the current count before fetching
      final currentCount = favoriteController.favorites.length;

      // Fetch favorites with pagination
      await favoriteController.fetchFavorites(page: page, limit: _limit);

      // Check if we got new data for pagination
      final newCount = favoriteController.favorites.length;
      if (page > 1 && newCount == currentCount) {
        _hasMore = false; // No new data received
      } else if (page == 1 && newCount < _limit) {
        _hasMore = false; // First page with less than limit means no more data
      } else if (page > 1 && (newCount - currentCount) < _limit) {
        _hasMore = false; // Received less than limit new items
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
    } finally {
      if (page == 1) isLoading.value = false;
      if (page > 1) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _currentPage++;
      _getFavoritesData(_currentPage);
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
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: mutedTextColor,
                size: 16.0,
              ),
            )),
        elevation: 0,
        centerTitle: true,
        title: HeadingText('Favorites'),
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
        child: Obx(() {
          if (isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          if (favoriteController.favorites.isEmpty && !_isLoadingMore) {
            return noData();
          }

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 16),
                StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 10,
                  children: favoriteController.favorites
                      .map((item) => ProductCard(
                            key: ValueKey(
                                item["Product"]["id"]), // Add unique key
                            isStagger: true,
                            data: item["Product"],
                          ))
                      .toList(),
                ),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}
