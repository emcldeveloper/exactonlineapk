import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/report_seller.dart';
import 'package:e_online/widgets/reviews.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductPage({required this.productData, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late bool isFavorite = false;
  late String selectedImage = widget.productData["ProductImages"][0]["id"];
  late List<String> productImages;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    // selectedImage = productImages.isNotEmpty ? productImages.first : '';
    var image = List.from(widget.productData["ProductImages"])
        .firstWhere((element) => element["id"] == selectedImage);
    print(widget.productData);
    print(image);
    print(selectedImage);
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

  void _showReportSellerBottomSheet() {
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
        child: const ReportSellerBottomSheet(),
      ),
    );
  }

  void _callSeller() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '+255627707434');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      debugPrint("Could not launch $phoneNumber");
    }
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
        'size': "2xl",
        'color': "Black",
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
        'size': "xl",
        'color': "Black",
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/black_tshirt.png",
          "assets/images/teal_tshirt.png",
        ],
        'rating': 4.5,
        'size': "s",
        'color': "Black",
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
        'size': "5xl",
        'color': "Black",
      },
    ];
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: secondaryColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("Product Details"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Get.to(CartPage());
            },
            child: Icon(
              Bootstrap.bag,
              color: Colors.black,
              size: 20.0,
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          InkWell(
            onTap: () {},
            child: Icon(
              Bootstrap.share,
              color: Colors.black,
              size: 20.0,
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
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
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: List.from(widget.productData["ProductImages"])
                          .firstWhere((element) =>
                              element["id"] == selectedImage)?["image"],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite icon container always on top of the image
                  Container(),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: ClipOval(
                        child: Container(
                          color: Colors.white.withOpacity(0.8),
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isFavorite
                                ? AntDesign.heart_fill
                                : AntDesign.heart_outline,
                            color: isFavorite ? Colors.red : Colors.black,
                            size: 22.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              spacer(),
              if (widget.productData["ProductImages"].isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.productData["ProductImages"]
                        .map<Widget>((image) {
                      final isSelected = image["id"] == selectedImage;
                      return GestureDetector(
                        onTap: () {
                          _updateSelectedImage(image["id"]);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: image["image"],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
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
                          widget.productData['name'] ?? '',
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                        ParagraphText(
                            "TZS ${toMoneyFormmat(widget.productData['sellingPrice'])}",
                            fontSize: 16.0),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16.0,
                          ),
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
                widget.productData['description'],
              ),
              spacer1(),
              ParagraphText(
                "Specifications",
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText(
                    "Size:",
                    color: mutedTextColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ParagraphText(
                    widget.productData['size'] ?? '',
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText(
                    "Color:",
                    color: mutedTextColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ParagraphText(
                    widget.productData['color'] ?? '',
                    fontWeight: FontWeight.bold,
                  ),
                ],
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
              // SizedBox(
              //   height: 240,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: relatedItems.length,
              //     itemBuilder: (context, index) {
              //       return Padding(
              //         padding: const EdgeInsets.only(right: 16.0),
              //         child: ProductCard(data: relatedItems[index]),
              //       );
              //     },
              //   ),
              // ),
              spacer1(),
              customButton(
                onTap: () => Get.to(() => const CartPage()),
                text: "Add to Cart",
              ),
              spacer(),
              customButton(
                onTap: _callSeller,
                text: "Call Seller",
                buttonColor: primaryColor,
                textColor: Colors.black,
              ),
              spacer(),
              customButton(
                onTap: () => Get.to(() => ChatPage()),
                text: "Message Seller",
                buttonColor: primaryColor,
                textColor: Colors.black,
              ),
              spacer(),
              customButton(
                onTap: () {
                  _showReportSellerBottomSheet();
                },
                text: "Report seller",
                buttonColor: Colors.transparent,
                textColor: Colors.red,
              ),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }
}
