import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final double? height;
  const ProductCard({required this.data, this.height, super.key});

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
        content:
            Text(isFavorite ? "Added to Favorites" : "Removed from Favorites"),
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
      child: SizedBox(
        width: 135,
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
                      height: widget.height ?? 135,
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
                            isFavorite
                                ? AntDesign.heart_fill
                                : AntDesign.heart_outline,
                            color: isFavorite ? Colors.red[800] : Colors.black,
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
                  Row(
                    children: [
                      if (widget.data['type'] == "ad")
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: ParagraphText("Ad", fontSize: 12),
                        ),
                      if (widget.data['type'] == "ad") const SizedBox(width: 8),
                      Expanded(
                        child: ParagraphText(
                          widget.data['title'],
                          fontSize: 12,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  ParagraphText(widget.data['price'],
                      fontWeight: FontWeight.bold, fontSize: 15.0),
                  if (widget.data['shipping'] == "free shipping")
                    ParagraphText(
                      widget.data['shipping'],
                      fontSize: 12,
                      color: Colors.red,
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
