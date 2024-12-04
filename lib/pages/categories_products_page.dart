import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class CategoriesProductsPage extends StatelessWidget {
  final String categoryName;

  CategoriesProductsPage({super.key, required this.categoryName});

  final List<Map<String, dynamic>> searchedResults = [
    {
      'title': "J.Crew T-shirt",
      'price': "25,000 TSH",
      'imageUrl': "assets/images/whiteTop.png",
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
    {
      'title': "J.Crew T-shirt",
      'price': "25,000 TSH",
      'imageUrl': "assets/images/blueTop.png",
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
    {
      'title': "J.Crew T-shirt",
      'price': "25,000 TSH",
      'imageUrl': "assets/images/maroonTop.png",
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
    {
      'title': "J.Crew T-shirt",
      'price': "25,000 TSH",
      'imageUrl': "assets/images/peachTop.png",
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
  ];

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
        title: HeadingText(categoryName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            spacer(),
            FilterTilesWidget(),
            spacer(),
            Expanded(
              child: ListView.builder(
                itemCount: searchedResults.length,
                itemBuilder: (context, index) {
                  final item = searchedResults[index];
                  return HorizontalProductCard(data: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
