import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

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
        child: ListView.builder(
          itemCount: productItems.length,
          itemBuilder: (context, index) {
            final item = productItems[index];

            return FavoriteCard(data: item);
          },
        ),
      ),
    );
  }
}
