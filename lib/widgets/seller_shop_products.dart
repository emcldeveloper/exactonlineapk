import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

Widget sellerShopProducts() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const FilterTilesWidget(),
        spacer1(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.65,
          ),
          itemCount: productItems.length,
          itemBuilder: (context, index) {
            return ProductCard(data: productItems[index], height: 175);
          },
        ),
      ],
    ),
  );
}
