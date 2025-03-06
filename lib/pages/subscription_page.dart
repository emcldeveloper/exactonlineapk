import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/subscription_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/payment_method.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int activeIndex = 0;
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  Rx<List<Map<String, dynamic>>> subscriptions =
      Rx<List<Map<String, dynamic>>>([]);

  @override
  void initState() {
    subscriptionController.getSubscriptions(page: 1, limit: 10, keyword: "");
    super.initState();
    trackScreenView("SubscriptionPage");
    _initializeSubscriptionDetails();
  }

  Future<void> _initializeSubscriptionDetails() async {
    try {
      final details = await subscriptionController.getSubscriptions(
        page: 1,
        limit: 20,
      );
      subscriptions.value = details;
    } catch (e) {
      print("Error fetching subscription details: $e");
    }
  }

  void _showPaymentBottomSheet(
      BuildContext context, String subscriptionId, String buttonText) {
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
        child: PaymentMethodBottomSheet(
            id: subscriptionId, buttonText: buttonText),
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
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText(
          "Select Subscription",
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (subscriptions.value.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                return Column(
                  children: subscriptions.value
                      .where((subscription) => subscription['days'] > 14)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> subscription = entry.value;
                    return SubscriptionCard(
                      data: subscription,
                      isActive: index == activeIndex,
                      onTap: () {
                        activeIndex = index;
                      },
                    );
                  }).toList(),
                );
              }),
              spacer3(),
              spacer3(),
              spacer3(),
              Obx(() {
                if (subscriptions.value.isEmpty) {
                  return const SizedBox();
                }

                return customButton(
                  onTap: () {
                    String selectedSubscriptionId =
                        subscriptions.value[activeIndex]['id'].toString();
                    _showPaymentBottomSheet(
                        context, selectedSubscriptionId, "Subscribe");
                  },
                  text: "Subscribe",
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
