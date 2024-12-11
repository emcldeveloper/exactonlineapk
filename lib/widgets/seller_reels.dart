
import 'package:e_online/pages/reels_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductMasonryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> productItems;

  const ProductMasonryGrid({required this.productItems, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: productItems.length,
          itemBuilder: (context, index) {
            return ReelCard(
              data: productItems[index],
              index: index,
            );
          },
        ),
      ),
    );
  }
}
