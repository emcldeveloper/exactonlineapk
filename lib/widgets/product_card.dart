import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ProductCard extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const ProductCard({required this.data, Key? key}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteItems = prefs.getStringList('favorites') ?? [];
    String productJson = jsonEncode(widget.data);

    setState(() {
      isFavorite = favoriteItems.contains(productJson);
    });
  }

  void _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteItems = prefs.getStringList('favorites') ?? [];
    String productJson = jsonEncode(widget.data);

    setState(() {
      if (favoriteItems.contains(productJson)) {
        favoriteItems.remove(productJson);
        isFavorite = false;
      } else {
        favoriteItems.add(productJson);
        isFavorite = true;
      }
    });

    await prefs.setStringList('favorites', favoriteItems);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? "Added to Favorites" : "Removed from Favorites"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(productData: widget.data),
          ),
        );
      },
      child: Container(
        width: 175,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.data['imageUrl'][0],
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: ClipOval(
                      child: Opacity(
                        opacity: 0.6,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isFavorite ? AntDesign.heart_fill : AntDesign.heart_outline,
                            color: isFavorite ? Colors.red : Colors.black,
                            size: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                    widget.data['title'],
                    fontWeight: FontWeight.bold,
                  ),
                  spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ParagraphText(
                          widget.data['price'],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          ParagraphText(widget.data['rating'].toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
