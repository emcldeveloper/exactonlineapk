import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/pages/categories_products_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/search_function.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final List<Map<String, dynamic>> searchKeywords = [
    {'name': 'Samsung Television', 'date': '10/11/2024'},
    {'name': 'router tplink', 'date': '10/11/2024'},
    {'name': 'sneakers', 'date': '10/11/2024'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
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
          title: buildSearchBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer(),
              ParagraphText("Search history", fontWeight: FontWeight.bold),
              spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchKeywords.map((filter) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: primaryColor,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: ParagraphText(filter['name']),
                  );
                }).toList(),
              ),
              spacer1(),
              ParagraphText("Categories", fontWeight: FontWeight.bold),
              spacer(),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesProductsPage(
                            categoryName: categories[index]['name'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: primaryColor,
                          ),
                          child: categories[index]['imageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.asset(
                                    categories[index]['imageUrl'],
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        spacer(),
                        ParagraphText(
                          categories[index]['name'],
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
