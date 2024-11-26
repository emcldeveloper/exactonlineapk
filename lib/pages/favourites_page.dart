import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of items with product details
    final List<Map<String, dynamic>> productItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/teal_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/red_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/black_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/green_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
       {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/pinkTop.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: HeadingText('Favorites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: productItems.length,
          itemBuilder: (context, index) {
            final item = productItems[index];
        
            return HorizontalProductCard(data: item);
          },
        ),
      ),
    );
  }
}
