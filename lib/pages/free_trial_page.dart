import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/subscription_controller.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/pages/subscription_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreeTrialPage extends StatefulWidget {
  final String shopId;
  FreeTrialPage({required this.shopId, super.key});

  @override
  State<FreeTrialPage> createState() => _FreeTrialPageState();
}

class _FreeTrialPageState extends State<FreeTrialPage> {
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  Rx<List<Map<String, dynamic>>> subscriptions =
      Rx<List<Map<String, dynamic>>>([]);
  String selectedSubscriptionId = '';

  @override
  void initState() {
    super.initState();
    trackScreenView("FreeTrialPage");
    _initializeSubscriptionDetails();
  }

  Future<void> _initializeSubscriptionDetails() async {
    try {
      final details =
          await subscriptionController.getSubscriptions(page: 1, limit: 20);

      if (details.isNotEmpty) {
        subscriptions.value = details;

        // Find the first subscription with 14 days
        final firstTrialSubscription = details.firstWhere(
          (sub) => sub["days"] == 14,
          orElse: () => {},
        );

        if (firstTrialSubscription.isNotEmpty) {
          setState(() {
            selectedSubscriptionId = firstTrialSubscription["id"];
          });
        }
      }
    } catch (e) {
      print("Error fetching subscription details: $e");
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: HeadingText(
          "14 days Free Trial",
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                spacer1(),
                Image.asset(
                  "assets/images/trial.png",
                  height: 250,
                  fit: BoxFit.contain,
                ),
                spacer(),
                HeadingText(
                  "Start Your 14-Day Free\nTrial Today!",
                  textAlign: TextAlign.center,
                ),
                spacer1(),
                ParagraphText(
                  "Take your business to the next levelwith our 14-day free trial. Explore powerful tools to list products, manage your store, and connect with our customers--all with no commitment. Start growing your sales today, risk free!",
                  color: mutedTextColor,
                  textAlign: TextAlign.center,
                ),
                spacer2(),
                spacer3(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      customButton(
                        onTap: () async {
                          if (selectedSubscriptionId.isEmpty) {
                            print("No valid subscription found");
                            return;
                          }
                          var payload = {
                            "SubscriptionId": selectedSubscriptionId,
                            "ShopId": widget.shopId,
                          };
                          Map<String, dynamic> subscribing =
                              await SubscriptionController()
                                  .Subscribing(payload);
                          print(subscribing);
                          Get.to(() => const MyShopPage(),
                              arguments: {'origin': 'FreeTrialPage'});
                        },
                        text: "Start 14 days free trial",
                      ),
                      spacer1(),
                      customButton(
                        onTap: () => Get.to(() => const SubscriptionPage()),
                        text: "Explore our packages",
                        buttonColor: primaryColor,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                spacer1(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
