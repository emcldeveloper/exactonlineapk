import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/review_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/pages/viewImage.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/cartIcon.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/report_seller.dart';
import 'package:e_online/widgets/reviews.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProductPage extends StatefulWidget {
  Map<String, dynamic> productData;

  ProductPage({required this.productData, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late String selectedImage = widget.productData["ProductImages"][0]["id"];
  late List<String> productImages;
  final UserController userController = Get.find();
  final ProductController productController = Get.put(ProductController());
  final FavoriteController favoriteController = Get.put(FavoriteController());
  final ReviewController reviewController = Get.put(ReviewController());
  late List<Map<String, dynamic>> reviews = [];
  RxBool isSharing = false.obs;
  // String userId = "";

  @override
  void initState() {
    super.initState();
    isFavorite.value = widget.productData.containsKey('Favorites') &&
        widget.productData['Favorites'] != null &&
        widget.productData['Favorites'].isNotEmpty;
    getData();
    _callProductReviews();
    _sendProductStats("view");
  }

  void getData() {}

  void _updateSelectedImage(String image) {
    setState(() {
      selectedImage = image;
    });
  }

  RxBool isFavorite = false.obs;

  void _toggleFavorite(Map<String, dynamic> product) async {
    var userId = userController.user.value['id'] ?? "";

    if (isFavorite.value) {
      var favoriteId = product['Favorites']?[0]['id'];
      if (favoriteId != null) {
        await favoriteController.deleteFavorite(favoriteId);
        isFavorite.value = false;
      }
    } else {
      var payload = {
        "ProductId": product['id'],
        "UserId": userId,
      };
      await favoriteController.addFavorite(payload);
      isFavorite.value = true;
    }
    favoriteController.fetchFavorites();
  }

  Future<void> _sendProductStats(String type) async {
    var userId = userController.user.value['id'] ?? "";
    try {
      var payload = {
        "ProductId": widget.productData['id'],
        "UserId": userId,
        "type": type
      };

      await productController.addProductStats(payload);
    } catch (e) {
      debugPrint("Error sending shop stats: $e");
    }
  }

  void _shareProduct() async {
    isSharing.value = true;

    await _sendProductStats("share");

    const String appLink = "https://api.exactonline.co.tz/open-app/";
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.exactmanpower.eOnline";
    const String appStoreLink = "https://apps.apple.com/app/idYOUR_APP_ID";

    String productId = widget.productData['id'];
    String productName =
        widget.productData['name'] ?? 'Check out this product!';
    String price = widget.productData['sellingPrice'] != null
        ? " TZS ${toMoneyFormmat(widget.productData['sellingPrice'])}"
        : '';

    String shareText = "$productName for a price of $price";

    String fullAppLink = "$appLink?productId=$productId";

    // Fetch image URL
    String imageUrl = widget.productData["ProductImages"][0]["image"];

    try {
      // Download image to temporary directory
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getTemporaryDirectory();
      final file = File('${documentDirectory.path}/product.jpg');
      await file.writeAsBytes(response.bodyBytes);

      // Share image with text
      await Share.shareXFiles([XFile(file.path)],
          text:
              "$shareText\n\nCheck out this product or explore more on ExactOnline! $fullAppLink");
    } catch (e) {
      print("Error sharing product image: $e");
      // If image fails, share text only
      await Share.share(
          "$shareText\n\nCheck out this product or explore more on ExactOnline! $fullAppLink");
    }
    isSharing.value = false;
  }

  List<Map<String, dynamic>> _callProductReviews() {
    List<Map<String, dynamic>> fetchedReviews =
        (widget.productData['ProductReviews'] as List<dynamic>)
            .map((review) => {
                  "name": review["User"]?["name"] ?? "NA",
                  "rating": review["rating"] ?? 0,
                  "description": review["description"] ?? "No description",
                })
            .toList();

    return fetchedReviews;
  }

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = reviews.fold(
        0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
    return totalRating / reviews.length;
  }

  void _showReviewsBottomSheet() async {
    reviews = _callProductReviews();
    var productId = widget.productData['id'];

    double averageRating = calculateAverageRating(reviews);
    await showModalBottomSheet(
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
          rating: averageRating,
          productId: productId,
          reviews: reviews,
        ),
      ),
    );
    setState(() {});
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

  var addingToCart = false.obs;
  CartProductController cartProductController = Get.find();
  RxInt index = 0.obs;
  @override
  Widget build(BuildContext context) {
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
            cartIcon(),
            SizedBox(
              width: 8.0,
            ),
            Obx(() => InkWell(
                  onTap: _shareProduct,
                  child: isSharing.value
                      ? SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Icon(
                          Bootstrap.share,
                          color: Colors.black,
                          size: 20.0,
                        ),
                )),
            SizedBox(
              width: 12.0,
            ),
          ],
        ),
        body: FutureBuilder(
            future:
                ProductController().getProduct(id: widget.productData["id"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              }
              var product = snapshot.requireData;
              widget.productData = product;
              // Set isFavorite based on fetched product
              isFavorite.value = product.containsKey('Favorites') &&
                  product['Favorites'] != null &&
                  product['Favorites'].isNotEmpty;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(00),
                            child: Container(
                              height: 300,
                              color: Colors.grey[100],
                              width: double.infinity,
                              child: CarouselSlider(
                                items: List.from(product["ProductImages"])
                                    .map((item) => GestureDetector(
                                          onTap: () {
                                            Get.to(() => ViewImage(
                                                  index: index.value,
                                                  images: List.from(product[
                                                          "ProductImages"])
                                                      .map((item) =>
                                                          item["image"]
                                                              as String)
                                                      .toList(),
                                                ));
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            child: CachedNetworkImage(
                                              imageUrl: item["image"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                options: CarouselOptions(
                                    onPageChanged: (current, reason) {
                                      index.value = current;
                                    },
                                    autoPlay: true,
                                    aspectRatio: 1,
                                    viewportFraction: 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(product),
                              child: ClipOval(
                                child: Obx(() => Container(
                                      color: Colors.white70,
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        isFavorite.value
                                            ? AntDesign.heart_fill
                                            : AntDesign.heart_outline,
                                        color: isFavorite.value
                                            ? Colors.red
                                            : Colors.black,
                                        size: 18.0,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                                  List.from(product["ProductImages"]).length,
                                  (index) => (index - 1) + 1,
                                  growable: true)
                              .map((item) => ClipOval(
                                      child: Container(
                                    width: 10,
                                    color: index.value == item
                                        ? Colors.orange
                                        : Colors.grey[300],
                                    height: 10,
                                  )))
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ParagraphText(
                                        product['name'] ?? '',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                      ParagraphText(
                                          "TZS ${toMoneyFormmat(product['sellingPrice'])}",
                                          fontSize: 16.0),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 16.0,
                                        ),
                                        const SizedBox(width: 2),
                                        ParagraphText(
                                          (product['rating'] ?? 0).toString(),
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
                              product['description'],
                            ),
                            spacer1(),
                            ParagraphText(
                              "Specifications",
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget
                                  .productData['specifications'].entries
                                  .map<Widget>((entry) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ParagraphText(
                                      "${entry.key}:", // Display the key
                                      color: mutedTextColor,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    ParagraphText(
                                      "${entry.value}", // Display the corresponding value
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),

                            spacer1(),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     HeadingText("Recomended"),
                            //     ParagraphText(
                            //       "See All",
                            //       color: mutedTextColor,
                            //       decoration: TextDecoration.underline,
                            //     ),
                            //   ],
                            // ),
                            // spacer1(),
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
                            if (product["CartProducts"].length < 1)
                              if (product["CartProducts"].length < 1)
                                Obx(
                                  () => customButton(
                                    loading: addingToCart.value,
                                    onTap: () async {
                                      addingToCart.value = true;
                                      await analytics.logEvent(
                                        name: 'add_to_cart',
                                        parameters: {
                                          'product_id': product["id"],
                                          'product_name': product['name'],
                                          'product_description':
                                              product['description'],
                                          'price': product['sellingPrice'],
                                        },
                                      );

                                      CartProductController().addCartProduct({
                                        "UserId":
                                            userController.user.value["id"],
                                        "ProductId": product["id"]
                                      }).then((res) {
                                        showSuccessSnackbar(
                                            title: "Added successfully",
                                            description:
                                                "Product is added to cart successfully");
                                        addingToCart.value = false;

                                        setState(() {});
                                        CartProductController()
                                            .getOnCartproducts();
                                      });
                                    },
                                    text: "Add to Cart",
                                  ),
                                ),
                            if (product["CartProducts"].length > 0)
                              customButton(
                                loading: addingToCart.value,
                                onTap: () async {
                                  await Get.to(() => CartPage());
                                  setState(() {});
                                },
                                text: "View in Cart",
                              ),

                            spacer(),
                            customButton(
                              onTap: () async {
                                await analytics.logEvent(
                                  name: 'call_seller',
                                  parameters: {
                                    'Shop_Id': product["Shop"]["id"],
                                    'product_id': product["id"],
                                    'product_name': product['name'],
                                    'product_description':
                                        product['description'],
                                    'price': product['sellingPrice'],
                                    'shopName': product["Shop"]["name"],
                                    'shopPhone': product["Shop"]["phone"],
                                    'from_page': 'ProductPage'
                                  },
                                );
                                _sendProductStats("call");
                                await launchUrl(Uri(
                                    scheme: "tel",
                                    path: product["Shop"]["phone"]));
                              },
                              text: "Call Seller",
                              buttonColor: primaryColor,
                              textColor: Colors.black,
                            ),
                            spacer(),
                            customButton(
                              onTap: () async {
                                await analytics.logEvent(
                                  name: 'chat_seller',
                                  parameters: {
                                    'Shop_Id': product["Shop"]["id"],
                                    'product_id': product["id"],
                                    'product_name': product['name'],
                                    'product_description':
                                        product['description'],
                                    'price': product['sellingPrice'],
                                    'shopName': product["Shop"]["name"],
                                    'shopPhone': product["Shop"]["phone"],
                                    'from_page': 'ProductPage'
                                  },
                                );
                                _sendProductStats("message");
                                ChatController().addChat({
                                  "ShopId": product["Shop"]["id"],
                                  "ProductId": product["id"],
                                  "UserId": userController.user.value["id"]
                                }).then((res) {
                                  print(res);
                                  Get.to(() => ConversationPage(res));
                                });
                              },
                              text: "Message Seller",
                              buttonColor: primaryColor,
                              textColor: Colors.black,
                            ),
                            spacer(),

                            spacer2(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
