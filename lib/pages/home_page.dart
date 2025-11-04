import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/notification_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/categories_products_page.dart';
import 'package:e_online/pages/home_page_sections/all_new_arrival_products.dart';
import 'package:e_online/pages/home_page_sections/all_products.dart';
import 'package:e_online/pages/home_page_sections/all_services.dart';
import 'package:e_online/pages/home_page_sections/new_arrival_products.dart';
import 'package:e_online/pages/home_page_sections/popular_services.dart';
import 'package:e_online/pages/notifications_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/ads_carousel.dart';
import 'package:e_online/widgets/cartIcon.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/homeReels.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  UserController userController = Get.find();
  NotificationController notificationController =
      Get.put(NotificationController());
  bool _checkedDeliveredPrompt = false;
  int _currentPage = 0;
  final List<String> carouselImages = [
    "assets/ads/ad1.jpg",
    "assets/ads/ad2.jpg",
    "assets/ads/ad3.jpg",
    "assets/ads/ad4.jpg",
  ];
  Rx<List> categories = Rx<List>([]);
  CartProductController cartProductController = CartProductController();
  late TabController _tabController; // Add TabController
  bool _tabReady = false; // Tracks initialization of TabController
  RxInt page = 0.obs; // Reactive page variable

  @override
  void initState() {
    super.initState();
    Get.put(cartProductController);
    // Fetch unread notifications count
    notificationController.getUnreadCount();
    // After first frame, check for delivered orders and prompt for OTP confirmation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptDeliveredOrder();
    });
    CategoriesController()
        .getCategories(page: 1, limit: 50, keyword: "")
        .then((res) {
      print(res);
      categories.value = [
        {"id": "All", "name": "All"}
      ];
      categories.value.addAll(res);
      _tabController =
          TabController(length: categories.value.length, vsync: this);
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) return; // Avoid multiple triggers
        page.value = _tabController.index; // Update page when tab changes
        print("Tab changed to: ${page.value}");
      });
      if (mounted) {
        setState(() {
          _tabReady = true;
        });
      } else {
        _tabReady = true;
      }
    });
    trackScreenView("HomePage");
  }

  @override
  void dispose() {
    _tabController.dispose(); // Clean up TabController
    super.dispose();
  }

  Future<void> _maybePromptDeliveredOrder() async {
    if (_checkedDeliveredPrompt) return; // avoid repeated prompts
    _checkedDeliveredPrompt = true;
    try {
      // Only customers confirm delivery
      final role = userController.user.value['role']?.toString().toLowerCase();
      if (role != 'customer') return;

      // Fetch orders with status DELIVERED (backend returns DELIVERED + CLOSED, we'll filter)
      final List<dynamic>? rows =
          await OrdersController().getMyOrders(1, 10, "", "DELIVERED");
      if (rows == null || rows.isEmpty) return;
      final delivered = rows
          .where((o) =>
              ((o['status']?.toString().toUpperCase()) ?? '') == 'DELIVERED')
          .toList();
      if (delivered.isEmpty) return;

      // Pick the most recently updated delivered order if available
      delivered.sort((a, b) {
        final aTime = DateTime.tryParse(a['updatedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['updatedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      final order = delivered.first;

      final otpController = TextEditingController();
      final formKey = GlobalKey<FormState>();
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Confirm Delivery'),
                const SizedBox(height: 4),
                Text(
                  'Order #${order['id'].toString().split('-').first}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: OrderedProductController()
                          .getUserOrderproducts(order['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 56,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData ||
                            (snapshot.data as List).isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final products = snapshot.data as List<dynamic>;
                        final displayCount =
                            products.length > 8 ? 8 : products.length;
                        final hasMore = products.length > displayCount;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SizedBox(
                            height: 100,
                            child: ListView.separated(
                              shrinkWrap: true,
                              primary: false,
                              scrollDirection: Axis.horizontal,
                              itemCount: displayCount,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final item = products[index];
                                String? imageUrl;
                                try {
                                  imageUrl = item["Product"]["ProductImages"][0]
                                          ["image"]
                                      ?.toString();
                                } catch (_) {}
                                final tile = ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: const Color(0xFFF2F2F2),
                                    child: imageUrl != null &&
                                            imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.image_not_supported,
                                            size: 20, color: Colors.grey),
                                  ),
                                );
                                if (hasMore && index == displayCount - 1) {
                                  final remaining =
                                      products.length - displayCount;
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      tile,
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      Text(
                                        "+$remaining",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return tile;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const Text(
                        'Enter the OTP code sent to you to confirm delivery.'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        focusColor: primary,
                        labelStyle: const TextStyle(color: Colors.black87),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary),
                        ),
                        labelText: 'OTP Code',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'OTP required';
                        }
                        if (v.trim().length < 4) {
                          return 'OTP seems too short';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Later',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primary),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx); // close dialog before request
                  final otp = otpController.text.trim();
                  try {
                    final res =
                        await OrdersController().editOrder(order['id'], {
                      'status': 'CLOSED',
                      'otp': otp,
                    });
                    if (res == null) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Failed to confirm delivery. Please try again.'),
                        ),
                      );
                      return;
                    }
                    if (res is Map &&
                        ((res['status'] == false) ||
                            (res['message']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains('invalid otp') ??
                                false))) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['message'] ?? 'Invalid OTP'),
                        ),
                      );
                      return;
                    }
                    // Success
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Delivery confirmed. Thank you!')),
                    );
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error confirming delivery')),
                    );
                  }
                },
                child: const Text('Confirm',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } catch (_) {
      // ignore errors silently to not block home page
    }
  }

  @override
  Widget build(BuildContext context) {
    var avatar = userController.user.value["image"];

    List<Map<String, dynamic>> filterProducts(String category) {
      if (category == "All") return productItems;
      return productItems
          .where((product) =>
              (product['category'] ?? '').toLowerCase() ==
              category.toLowerCase())
          .toList();
    }

    Widget buildProductList(String category) {
      final filteredProducts = filterProducts(category);

      if (filteredProducts.isEmpty) {
        return Center(child: Text("No $category Available"));
      }

      return categories.value.length < 1
          ? CircularProgressIndicator(
              color: Colors.black,
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdsCarousel(),
                    spacer1(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText("New Arrival",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(const AllNewArrivalProducts());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.grey.withAlpha(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: ParagraphText(
                                      "See All",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        spacer1(),
                        NewArrivalProducts(),
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 242, 242, 242),
                        ),
                        // spacer1(),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           ParagraphText("For You",
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 18.0),
                        //         ],
                        //       ),
                        //       InkWell(
                        //         onTap: () {
                        //           Get.to(const AllForYouProducts());
                        //         },
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(50),
                        //               color: Colors.grey.withAlpha(30)),
                        //           child: Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 10, vertical: 6),
                        //             child: ParagraphText(
                        //               "See All",
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 13,
                        //               color: mutedTextColor,
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // spacer1(),
                        // ForYouProducts(),
                        // Container(
                        //   height: 8,
                        //   width: double.infinity,
                        //   color: const Color.fromARGB(255, 242, 242, 242),
                        // ),
                        spacer1(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText("Services",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(AllServices());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.grey.withAlpha(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: ParagraphText(
                                      "See All",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        spacer1(),
                        PopularServices(),
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 242, 242, 242),
                        ),
                        spacer1(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HeadingText("All Products"),
                            ],
                          ),
                        ),
                        spacer1(),
                        AllProducts(),
                        spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            );
    }

    return GetX<CategoriesController>(
      init: CategoriesController(),
      builder: (find) {
        if (categories.value.isEmpty || !_tabReady) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: mainColor,
            elevation: 0,
            leading: Container(),
            leadingWidth: 1.0,
            title: HeadingText("ExactOnline"),
            actions: [
              cartIcon(),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Get.to(SearchPage());
                },
                child: const Icon(
                  Bootstrap.search,
                  color: Colors.black,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  await Get.to(NotificationsPage());
                  // Refresh unread count when returning from notifications page
                  notificationController.getUnreadCount();
                },
                child: Stack(
                  children: [
                    const Icon(
                      Bootstrap.bell,
                      color: Colors.black,
                      size: 20.0,
                    ),
                    Obx(() => notificationController.unreadCount.value > 0
                        ? Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${notificationController.unreadCount.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  Get.to(const ProfilePage());
                },
                child: ClipOval(
                  child: avatar != null
                      ? CachedNetworkImage(
                          imageUrl: avatar,
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: HugeIcon(
                              icon: AntDesign.user_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              HomeReels(),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: mainColor,
                    toolbarHeight: 5,
                    elevation: 0,
                    leading: Container(),
                    leadingWidth: 1.0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(
                          () => TabBar(
                            controller:
                                _tabController, // Use custom TabController
                            tabAlignment: TabAlignment.start,
                            dividerColor:
                                const Color.fromARGB(255, 234, 234, 234),
                            isScrollable: true,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),

                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            labelPadding: EdgeInsets.all(0),
                            tabs: categories.value
                                .map((category) => Tab(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: category["name"] == "All"
                                                ? 16
                                                : 5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            color: page.value ==
                                                    categories.value
                                                        .indexOf(category)
                                                ? primary
                                                : Colors.grey[100],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 3),
                                              child: Text(
                                                "${category["name"]} ${category["name"] != "All" ? "(${category["productsCount"] ?? 0})" : ""}",
                                                style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    color: page.value ==
                                                            categories.value
                                                                .indexOf(
                                                                    category)
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: categories.value.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : TabBarView(
                          controller:
                              _tabController, // Use custom TabController
                          children: categories.value.map((category) {
                            return category["id"] == "All"
                                ? buildProductList(category["id"])
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: CategoriesProductsPage(
                                      category: category,
                                      hideAppBar: true,
                                    ),
                                  );
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget carouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(carouselImages.length, (int number) => number++)
          .map((i) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 7,
              width: i == _currentPage ? 15 : 7,
              color:
                  i == _currentPage ? secondaryColor : const Color(0xffEBEBEB),
            ),
          ),
        );
      }).toList(),
    );
  }
}
