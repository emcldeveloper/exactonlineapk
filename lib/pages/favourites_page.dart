import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouritesPage extends StatelessWidget {
  FavouritesPage({super.key});
  final FavoriteController favoriteController = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
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
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (favoriteController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteController.favorites.isEmpty) {
            return const Center(
              child: Text("No favorite products yet.",
                  style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            itemCount: favoriteController.favorites.length,
            itemBuilder: (context, index) {
              final item = favoriteController.favorites[index];

              return FavoriteCard(data: item);
            },
          );
        }),
      ),
    );
  }
}
