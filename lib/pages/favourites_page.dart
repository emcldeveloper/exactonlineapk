import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:flutter/material.dart';
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
      // Assuming fetchFavorites accepts page and limit parameters
      await favoriteController.fetchFavorites(page: page, limit: _limit);
      if (favoriteController.favorites.length < _limit * page) {
        _hasMore = false; // No more data if fewer items than expected
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
        elevation: 0,
        leading: Container(),
        leadingWidth: 1.0,
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

          return ListView.builder(
            controller: _scrollController, // Attach ScrollController
            itemCount: favoriteController.favorites.length +
                (_isLoadingMore ? 1 : 0), // Add loading item
            itemBuilder: (context, index) {
              if (index == favoriteController.favorites.length &&
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
              final item = favoriteController.favorites[index];
              return FavoriteCard(data: item["Product"]);
            },
          );
        }),
      ),
    );
  }
}
