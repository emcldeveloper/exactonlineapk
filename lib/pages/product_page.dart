import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/reviews.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductPage extends StatefulWidget {
  final Map<dynamic, dynamic> productData;

  const ProductPage({required this.productData, Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late bool isFavorite = false;
  late String selectedImage;
  late List<String> productImages;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    productImages = _initializeImages();
    selectedImage = productImages.isNotEmpty ? productImages.first : '';
  }

  List<String> _initializeImages() {
    if (widget.productData['images'] != null) {
      return List<String>.from(widget.productData['images']);
    } else if (widget.productData['imageUrl'] != null) {
      if (widget.productData['imageUrl'] is List) {
        return List<String>.from(widget.productData['imageUrl']);
      } else if (widget.productData['imageUrl'] is String) {
        return [widget.productData['imageUrl'] as String];
      }
    }
    return [];
  }

  void _updateSelectedImage(String image) {
    setState(() {
      selectedImage = image;
    });
  }

  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteItems = prefs.getStringList('favorites') ?? [];
    String productJson = jsonEncode(widget.productData);

    setState(() {
      isFavorite = favoriteItems.contains(productJson);
    });
  }

  void _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteItems = prefs.getStringList('favorites') ?? [];
    String productJson = jsonEncode(widget.productData);

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

  void _showReviewsBottomSheet() {
    final List<Map<String, dynamic>> sampleReviews = [
      {
        'name': 'John Doe',
        'comment': 'Great product!',
        'rating': 5,
      },
      {
        'name': 'John Chuma',
        'comment':
            'I used bough this product it is very nice , i would recommend you guys to buy this',
        'rating': 3,
      },
      {
        'name': 'John Doe',
        'comment': 'Great product!',
        'rating': 4.5,
      },
      {
        'name': 'John Coe',
        'comment': 'Great product!',
        'rating': 2,
      },
      {
        'name': 'John Doe',
        'comment':
            'I used bough this product it is very nice , i would recommend you guys to buy this',
        'rating': 5,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReviewBottomSheet(
          rating: 4.5,
          reviews: sampleReviews,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> relatedItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/teal_tshirt.png",
          "assets/images/red_tshirt.png",
        ],
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/red_tshirt.png",
          "assets/images/teal_tshirt.png",
          "assets/images/green_tshirt.png"
        ],
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/black_tshirt.png",
          "assets/images/teal_tshirt.png",
        ],
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/green_tshirt.png",
          "assets/images/black_tshirt.png",
          "assets/images/teal_tshirt.png"
        ],
        'rating': 4.5,
      },
    ];
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: secondaryColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Product Details"),
        centerTitle: true,
        actions: [
          Icon(Icons.share),
          SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      selectedImage,
                      height: 430,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 15,
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
              spacer(),
              if (productImages.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: productImages.map((image) {
                      final isSelected = image == selectedImage;
                      return GestureDetector(
                        onTap: () => _updateSelectedImage(image),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              image,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParagraphText(
                          widget.productData['title'] ?? '',
                          fontWeight: FontWeight.bold,
                        ),
                        ParagraphText(
                          widget.productData['price'] ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          ParagraphText(
                            (widget.productData['rating'] ?? 0).toString(),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showReviewsBottomSheet,
                        child: ParagraphText(
                          "View reviews",
                          color: mutedTextColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              spacer(),
              ParagraphText(
                "Lorem ipsum dolor sit amet consectetur. Congue gravida ullamcorper ac diam eget facilisis tincidunt. Cursus massa etiam tempor magnis.",
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("For You"),
                  ParagraphText(
                    "See All",
                    color: mutedTextColor,
                    decoration: TextDecoration.underline,
                  ),
                ],
              ),
              spacer1(),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ProductCard(data: relatedItems[index]),
                    );
                  },
                ),
              ),
              spacer1(),
              customButton(
                onTap: () => Get.to(() => const HomePage()),
                text: "Call Seller",
              ),
              spacer(),
              customButton(
                onTap: () => Get.to(() => const HomePage()),
                text: "Message Seller",
                buttonColor: mutedTextColor,
                textColor: primaryColor,
              ),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }
}
