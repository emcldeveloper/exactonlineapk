import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/controllers/location_controller.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/edit_register_as_seller_page.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/register_as_seller_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/shop_subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/active_business_selection.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/setting_shop_details.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
// ... (previous imports remain the same)

class SettingMyshopPage extends StatefulWidget {
  var from;
  SettingMyshopPage({super.key, this.from});

  @override
  State<SettingMyshopPage> createState() => _SettingMyshopPageState();
}

class _SettingMyshopPageState extends State<SettingMyshopPage> {
  var isLoading = false.obs;
  var isLoadingTime = false.obs;
  final UserController userController = Get.find();
  final ShopController shopController = Get.put(ShopController());
  final LocationController locationController = Get.put(LocationController());
  var _location = null;
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Map<String, String> selectedTimes = {};

  String userId = "";
  List<dynamic> shopList = [];
  Rx<Map<String, dynamic>>? selectedBusiness = Rx<Map<String, dynamic>>({});

  @override
  void initState() {
    super.initState();
    trackScreenView("SettingMyshopPage");
    _loadSelectedShopDetails();
    userId = userController.user.value['id'] ?? "";
    shopList = userController.user.value['Shops'] ?? [];
  }

  RxList<dynamic> shopCalendars = <dynamic>[].obs;

  Future _loadSelectedShopDetails() async {
    isLoadingTime.value = true;
    final businessId = await SharedPreferencesUtil.getSelectedBusiness();
    var shopDetails = await shopController.getShopDetails(businessId);

    setState(() {
      selectedBusiness?.value = shopDetails ?? {};
      userController.user.value["selectedShop"] = shopDetails;
      shopCalendars.value = shopDetails["ShopCalenders"] ?? [];

      if (shopDetails.isNotEmpty &&
          shopDetails.containsKey("shopLat") &&
          shopDetails.containsKey("shopLong")) {
        _location = {
          "shopLat": shopDetails["shopLat"],
          "shopLong": shopDetails["shopLong"]
        };
      }
    });
    isLoadingTime.value = false;
  }

  Future<void> _updateLocation() async {
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();
      isLoading.value = true;
      Position? position = await locationController.getCurrentLocation();
      isLoading.value = false;
      if (position != null) {
        await shopController.updateShopData(businessId, _location);
        setState(() {
          _location = {
            "shopLat": position.latitude,
            "shopLong": position.longitude
          };
        });
      } else {
        setState(() {
          _location = "Failed to get location";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void showSelectBusinessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ActiveBusinessSelection(),
    ).then((selectedBusiness) {
      if (selectedBusiness != null) {
        print("Selected Business: $selectedBusiness");
      }
    });
  }

  void showSetTimeBottomSheet(String day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SettingShopDetails(
        onSave: (openTime, closeTime, is24Hours, isClosed, applyToAll,
            selectedDays) async {
          if (!mounted) return;

          final businessId = await SharedPreferencesUtil.getSelectedBusiness();
          List<String> daysToUpdate = applyToAll ? selectedDays : [day];
          Get.snackbar("Updating...", "Updating You Calender",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedTick01, color: Colors.white));
          for (String currentDay in daysToUpdate) {
            setState(() {
              if (isClosed) {
                selectedTimes[currentDay] = "Closed";
              } else if (is24Hours) {
                selectedTimes[currentDay] = "24 Hours";
              } else {
                String openTimeStr =
                    openTime != null ? openTime.format(context) : "Not Set";
                String closeTimeStr =
                    closeTime != null ? closeTime.format(context) : "Not Set";
                selectedTimes[currentDay] = "$openTimeStr - $closeTimeStr";
              }
            });

            var payload = {
              "ShopId": businessId,
              "day": currentDay,
              "openTime": is24Hours
                  ? "00:00"
                  : (openTime != null ? _formatTime(openTime) : null),
              "closeTime": is24Hours
                  ? "23:59"
                  : (closeTime != null ? _formatTime(closeTime) : null),
              "isOpen": (!isClosed).toString(),
            };

            try {
              await shopController.createShopCalendar(payload);
            } catch (e) {
              Get.snackbar(
                  "Error", "Failed to save Shop-Calendar for $currentDay",
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel02,
                      color: Colors.white));
            }
          }

          await _loadSelectedShopDetails();
        },
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 16,
          ),
          onPressed: () {
            if (widget.from == 'shoppingPage') {
              Get.back();
            } else if (widget.from == 'formPage') {
              Get.offAll(() => const ProfilePage());
            } else {
              Get.offAll(() => const MainPage());
            }
          },
        ),
        title: HeadingText("Settings"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: isLoadingTime.value
          ? Center(
              child: const CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => selectedBusiness?.value['isSubscribed'] == true
                        ? ShopSubscriptionCard(
                            data: selectedBusiness?.value['ShopSubscription'])
                        : ParagraphText("No Active Subscription",
                            color: mutedTextColor)),
                    spacer1(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ParagraphText(
                          "Current business",
                          fontWeight: FontWeight.bold,
                        ),
                        InkWell(
                          onTap: showSelectBusinessBottomSheet,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: ParagraphText(
                                "Switch",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    spacer1(),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => ParagraphText(
                                        selectedBusiness?.value['name'] ??
                                            "Name",
                                        fontWeight: FontWeight.bold,
                                      )),
                                  spacer(),
                                  Obx(() => ParagraphText(
                                        selectedBusiness?.value['createdAt'] ??
                                            "Date",
                                        color: mutedTextColor,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (selectedBusiness != null &&
                                          selectedBusiness?.value["id"] !=
                                              null) {
                                        await shopController.deleteShop(
                                            selectedBusiness?.value["id"]);
                                      } else {
                                        print("No business selected");
                                      }
                                    },
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDelete01,
                                      color: Colors.grey,
                                      size: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      if (selectedBusiness != null &&
                                          selectedBusiness?.value["id"] !=
                                              null) {
                                        Get.to(() => EditRegisterAsSellerPage(
                                            selectedBusiness?.value["id"]));
                                      } else {
                                        print("No business selected");
                                      }
                                    },
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedPencilEdit02,
                                      color: Colors.grey,
                                      size: 22.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText(
                                    "Location",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  spacer(),
                                  ParagraphText(
                                    ((_location != null) &&
                                            _location?["shopLat"] != null &&
                                            _location?["shopLong"] != null)
                                        ? 'Lat: ${_location?["shopLat"]}, Long: ${_location?["shopLong"]}'
                                        : 'No selected',
                                    color: mutedTextColor,
                                  ),
                                ],
                              ),
                              Obx(() {
                                return isLoading.value
                                    ? const CustomLoader(
                                        color: Colors.black,
                                        size: 12.0,
                                      )
                                    : InkWell(
                                        onTap: _updateLocation,
                                        child: HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedLocation01,
                                          color: Colors.grey,
                                          size: 22.0,
                                        ),
                                      );
                              }),
                            ],
                          ),
                          spacer(),
                          ParagraphText(
                            "Calendar",
                            fontWeight: FontWeight.bold,
                          ),
                          spacer(),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Obx(() {
                                return Column(
                                  children: daysOfWeek.map((day) {
                                    final calendarEntry =
                                        shopCalendars.firstWhere(
                                      (calendar) => calendar["day"] == day,
                                      orElse: () => null,
                                    );

                                    String statusText = "Not-set";
                                    if (calendarEntry != null) {
                                      statusText = calendarEntry["isOpen"] ==
                                              false
                                          ? "Closed"
                                          : "${calendarEntry["openTime"]} - ${calendarEntry["closeTime"]}";
                                    }

                                    return Container(
                                      width: constraints.maxWidth,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ParagraphText(day,
                                              color: mutedTextColor),
                                          Row(
                                            children: [
                                              ParagraphText(statusText,
                                                  color: mutedTextColor),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () =>
                                                    showSetTimeBottomSheet(day),
                                                child: HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedPencilEdit02,
                                                  color: Colors.grey,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    spacer1(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ParagraphText(
                            "Other businesses",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => const RegisterAsSellerPage());
                          },
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            color: Colors.black,
                            size: 22.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    spacer1(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shopList.length,
                      itemBuilder: (context, index) {
                        final shop = shopList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              shop['shopImage'] != null
                                  ? CachedNetworkImage(
                                      imageUrl: shop['shopImage'])
                                  : ClipOval(
                                      child: Container(
                                        height: 40,
                                        color: Colors.grey[200],
                                        width: 40,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.image_outlined),
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ParagraphText(
                                      shop["name"] ?? "Unknown Shop",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    spacer(),
                                    ParagraphText(
                                      shop['createdAt'] != null
                                          ? "Created on: ${shop['createdAt']}"
                                          : "No Date available",
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
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
