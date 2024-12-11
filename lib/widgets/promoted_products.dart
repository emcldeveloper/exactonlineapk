import 'package:e_online/widgets/ad_card.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> promotedItems = [
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
];

Widget PromotedProducts() {
  return Container(
    child: Column(
      children: promotedItems.map((item) {
        return AdCard(data: item);
      }).toList(),
    ),
  );
}
