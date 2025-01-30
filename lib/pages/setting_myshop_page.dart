import 'package:e_online/controllers/location_controller.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/edit_register_as_seller_page.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/register_as_seller_page.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/active_business_selection.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/setting_shop_details.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/subscription_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

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
    _loadSelectedShopDetails();
    userId = userController.user.value['id'] ?? "";
    shopList = userController.user.value['Shops'] ?? [];
  }

  RxList<dynamic> shopCalendars = <dynamic>[].obs;

  Future _loadSelectedShopDetails() async {
    isLoadingTime.value = true;
    final businessId = await SharedPreferencesUtil.getSelectedBusiness();
    print("Duka");
    print(businessId);
    // if (businessId != null) {
    //   List businesses = userController.user.value['Shops'];
    //   print(businessId);
    //   var businessList =
    //       businesses.where((business) => business["id"] == businessId);
    //   selectedBusiness?.value =
    //       businesses.where((business) => business["id"] == businessId).first;
    //   print(selectedBusiness);
    // }
    var shopDetails = await shopController.getShopDetails(businessId);
    userController.user.value["selectedShop"] = shopDetails;
    shopCalendars.value = shopDetails["ShopCalenders"] ?? [];
    isLoadingTime.value = false;
  }

  // Update location
  Future<void> _updateLocation() async {
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
  }

  final activeSubscription = subscriptions.firstWhere(
    (sub) => sub["status"] == "Active",
    orElse: () => {},
  );

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
          onSave: (openTime, closeTime, is24Hours, isClosed) async {
        if (!mounted) return;

        setState(() {
          if (isClosed) {
            selectedTimes[day] = "Closed";
          } else if (is24Hours) {
            selectedTimes[day] = "24 Hours";
          } else {
            String openTimeStr =
                openTime != null ? openTime.format(context) : "Not Set";
            String closeTimeStr =
                closeTime != null ? closeTime.format(context) : "Not Set";
            selectedTimes[day] = "$openTimeStr - $closeTimeStr";
          }
        });

        // Prepare data payload to send to API
        var payload = {
          "ShopId": selectedBusiness?.value!["id"],
          "day": day,
          "openTime": is24Hours
              ? "00:00"
              : (openTime != null ? _formatTime(openTime) : null),
          "closeTime": is24Hours
              ? "23:59"
              : (closeTime != null ? _formatTime(closeTime) : null),
          "isOpen": (!isClosed).toString(),
        };

        // Send data to API
        try {
          await shopController.createShopCalendar(payload);
        } catch (e) {
          // Handle the error here
          Get.snackbar("Error", "Failed to save Shop-Calendar",
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
        }
      }),
    );
  }

// Helper function to format TimeOfDay to HH:mm string
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagraphText(
                "My Subscription",
                fontWeight: FontWeight.bold,
              ),
              spacer1(),
              activeSubscription.isNotEmpty
                  ? SubscriptionCard(
                      data: activeSubscription,
                      isActive: activeSubscription["status"] == "Active",
                      onTap: () {},
                    )
                  : ParagraphText(
                      "No Active Subscription",
                      color: mutedTextColor,
                    ),
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
              // Business Details
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
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ParagraphText(
                                selectedBusiness?.value['name'] ?? "Name",
                                fontWeight: FontWeight.bold,
                              ),
                              spacer(),
                              ParagraphText(
                                selectedBusiness?.value['createdAt'] ?? "Date",
                                color: mutedTextColor,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (selectedBusiness != null &&
                                    selectedBusiness?.value["id"] != null) {
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
                                    selectedBusiness?.value["id"] != null) {
                                  Get.to(() => EditRegisterAsSellerPage(
                                      selectedBusiness?.value["id"]));
                                } else {
                                  // Handle the case where no business is selected
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
                              _location != null
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
                                    icon: HugeIcons.strokeRoundedLocation01,
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
                    Obx(() {
                      return isLoadingTime.value
                          ? const CustomLoader(
                              color: Colors.black,
                              size: 12.0,
                            )
                          : Column(
                              children: daysOfWeek.map((day) {
                                final calendarEntry = shopCalendars.firstWhere(
                                  (calendar) => calendar["day"] == day,
                                  orElse: () => null,
                                );

                                String statusText = "Not-set";
                                if (calendarEntry != null) {
                                  if (calendarEntry["isOpen"] == false) {
                                    statusText = "Closed";
                                  } else {
                                    statusText =
                                        "${calendarEntry["openTime"]} - ${calendarEntry["closeTime"]}";
                                  }
                                }

                                return Column(
                                  children: [
                                    Row(
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
                                              onTap: () {
                                                showSetTimeBottomSheet(day);
                                              },
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
                                    spacer(),
                                  ],
                                );
                              }).toList(),
                            );
                    }),
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
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: shop['shopImage'] != null
                              ? NetworkImage(shop['shopImage'])
                              : const AssetImage('assets/images/avatar.png')
                                  as ImageProvider,
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
