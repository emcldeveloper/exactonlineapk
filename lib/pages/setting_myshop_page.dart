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
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/active_business_selection.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/setting_shop_details.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
// ... (previous imports remain the same)

class SettingMyshopPage extends StatefulWidget {
  final dynamic from;
  const SettingMyshopPage({super.key, this.from});

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

          // Validate that we have the required times when not closed or 24 hours
          if (!isClosed &&
              !is24Hours &&
              (openTime == null || closeTime == null)) {
            Get.snackbar(
                "Error", "Please select both opening and closing times",
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel02,
                    color: Colors.white));
            return;
          }

          final businessId = await SharedPreferencesUtil.getSelectedBusiness();
          List<String> daysToUpdate = applyToAll ? selectedDays : [day];
          Get.snackbar("Updating...", "Updating Your Calendar",
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
                    openTime != null ? _formatTimeDisplay(openTime) : "Not Set";
                String closeTimeStr = closeTime != null
                    ? _formatTimeDisplay(closeTime)
                    : "Not Set";
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
              print("Error creating shop calendar: $e"); // Add debug print
              Get.snackbar("Error",
                  "Failed to save Shop-Calendar for $currentDay: ${e.toString()}",
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

  String _formatTimeDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  void _confirmDeleteShop() {
    if (selectedBusiness?.value["id"] == null) {
      Get.snackbar("Error", "No business selected to delete",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Delete Business"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to delete this business?"),
            const SizedBox(height: 8),
            Text(
              '"${selectedBusiness?.value["name"] ?? "Unknown Business"}"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. All data associated with this business will be permanently deleted.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _deleteShop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShop() async {
    try {
      Get.back(); // Close the dialog

      // Show loading
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Deleting business..."),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Delete the shop
      await shopController.deleteShop(selectedBusiness?.value["id"]);

      // Close loading dialog
      Get.back();

      // Refresh user data to update shop list
      final updatedUserData = await userController.getUserDetails();
      if (updatedUserData != null) {
        userController.user.value = updatedUserData;
        setState(() {
          shopList = userController.user.value['Shops'] ?? [];
        });
      }

      // If the deleted shop was the current one, redirect to main page
      final currentBusinessId =
          await SharedPreferencesUtil.getSelectedBusiness();
      if (currentBusinessId == selectedBusiness?.value["id"]) {
        // Clear the selected business
        await SharedPreferencesUtil.saveSelectedBusiness("");

        Get.snackbar("Success",
            "Business deleted successfully. Please select another business to continue.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTick01, color: Colors.white));

        // Navigate back to main page or business selection
        Get.offAll(() => const MainPage());
      } else {
        // Just refresh the current page
        await _loadSelectedShopDetails();
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar("Error", "Failed to delete business: ${e.toString()}",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));

      print("Error deleting shop: $e");
    }
  }

  void _confirmDeleteSpecificShop(Map<String, dynamic> shop) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Business"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to delete this business?"),
            const SizedBox(height: 8),
            Text(
              '"${shop["name"] ?? "Unknown Business"}"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. All data associated with this business will be permanently deleted.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _deleteSpecificShop(shop),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSpecificShop(Map<String, dynamic> shop) async {
    try {
      Get.back(); // Close the dialog

      // Show loading
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Deleting business..."),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Delete the shop
      await shopController.deleteShop(shop["id"]);

      // Close loading dialog
      Get.back();

      // Refresh user data to update shop list
      final updatedUserData = await userController.getUserDetails();
      if (updatedUserData != null) {
        userController.user.value = updatedUserData;
        setState(() {
          shopList = userController.user.value['Shops'] ?? [];
        });
      }

      // If the deleted shop was the current one, handle appropriately
      final currentBusinessId =
          await SharedPreferencesUtil.getSelectedBusiness();
      if (currentBusinessId == shop["id"]) {
        // Clear the selected business
        await SharedPreferencesUtil.saveSelectedBusiness("");

        Get.snackbar("Success",
            "Current business deleted successfully. Please select another business to continue.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTick01, color: Colors.white));

        // Navigate back to main page
        Get.offAll(() => const MainPage());
      } else {
        Get.snackbar("Success", "Business deleted successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTick01, color: Colors.white));

        // Just refresh the current page
        await _loadSelectedShopDetails();
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar("Error", "Failed to delete business: ${e.toString()}",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel02, color: Colors.white));

      print("Error deleting specific shop: $e");
    }
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
                    // Obx(() => selectedBusiness?.value['isSubscribed'] == true
                    //     ? ShopSubscriptionCard(
                    //         data: selectedBusiness?.value['ShopSubscription'])
                    //     : ParagraphText("No Active Subscription",
                    //         color: mutedTextColor)),
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
                                    onTap: () => _confirmDeleteShop(),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDelete01,
                                      color: Colors.red,
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
                            "All businesses",
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
                        bool isCurrentShop =
                            shop['id'] == selectedBusiness?.value['id'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentShop
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isCurrentShop
                                  ? Border.all(color: Colors.orange, width: 1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                shop['shopImage'] != null
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: shop['shopImage'],
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 40,
                                            width: 40,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.image_outlined),
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child: Container(
                                          height: 40,
                                          color: Colors.grey[200],
                                          width: 40,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.business,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ParagraphText(
                                              shop["name"] ?? "Unknown Shop",
                                              fontWeight: FontWeight.bold,
                                              color: isCurrentShop
                                                  ? Colors.orange
                                                  : Colors.black,
                                            ),
                                          ),
                                          if (isCurrentShop)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "Current",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      spacer(),
                                      ParagraphText(
                                        shop['createdAt'] != null
                                            ? "Created on: ${shop['createdAt']}"
                                            : "No Date available",
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (shop["id"] != null) {
                                          Get.to(() => EditRegisterAsSellerPage(
                                              shop["id"]));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedPencilEdit02,
                                          color: Colors.blue,
                                          size: 18.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () =>
                                          _confirmDeleteSpecificShop(shop),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedDelete01,
                                          color: Colors.red,
                                          size: 18.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
