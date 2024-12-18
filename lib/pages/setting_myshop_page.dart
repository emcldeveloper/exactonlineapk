import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/active_business_selection.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/setting_shop_details.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/subscription_card.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingMyshopPage extends StatefulWidget {
  const SettingMyshopPage({super.key});

  @override
  State<SettingMyshopPage> createState() => _SettingMyshopPageState();
}

class _SettingMyshopPageState extends State<SettingMyshopPage> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Map<String, String> selectedTimes = {
    'Monday': 'Not Set',
    'Tuesday': 'Not Set',
    'Wednesday': 'Not Set',
    'Thursday': 'Not Set',
    'Friday': 'Not Set',
    'Saturday': 'Not Set',
    'Sunday': 'Not Set',
  };

  final List<Map<String, String>> shopList = [
    {"name": "Vunjabei shop", "createdAt": "Created at 28/10/2024"},
    {"name": "Bamba shop", "createdAt": "Created at 27/10/2024"},
    {"name": "Niko shop", "createdAt": "Created at 26/10/2024"},
  ];

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
        onSave: (openTime, closeTime, is24Hours, isClosed) {
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
        },
      ),
    );
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
            Navigator.pop(context);
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText(
                              "Vunjabei shop",
                              fontWeight: FontWeight.bold,
                            ),
                            spacer(),
                            ParagraphText(
                              "Created at 20/05/2024",
                              color: mutedTextColor,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete01,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {},
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedEdit01,
                                color: Colors.grey,
                                size: 20.0,
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
                              "Not selected",
                              color: mutedTextColor,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            color: Colors.grey,
                            size: 20.0,
                          ),
                        ),
                      ],
                    ),
                    spacer(),
                    ParagraphText(
                      "Calendar",
                      fontWeight: FontWeight.bold,
                    ),
                    spacer(),
                    Column(
                      children: daysOfWeek.map((day) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText(
                                  day,
                                  color: mutedTextColor,
                                ),
                                Row(
                                  children: [
                                    ParagraphText(
                                      selectedTimes[day]!,
                                      color: mutedTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        showSetTimeBottomSheet(day);
                                      },
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedEdit01,
                                        color: Colors.grey,
                                        size: 20.0,
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
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    color: Colors.black,
                    size: 20.0,
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
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            'assets/images/avatar.png',
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
                                shop["createdAt"] ?? "No Date",
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
