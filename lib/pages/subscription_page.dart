import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/payment_method.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/subscription_card.dart';
import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int activeIndex = 0;

  void _showPaymentBottomSheet(BuildContext context, String buttonText) {
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
        child: PaymentMethodBottomSheet(buttonText: buttonText),
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
              Column(
                children: subscriptions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> subscription = entry.value;
                  return SubscriptionCard(
                    data: subscription,
                    isActive: index == activeIndex,
                    onTap: () {
                      setState(() {
                        activeIndex = index;
                      });
                    },
                  );
                }).toList(),
              ),
              spacer3(),
              spacer3(),
              spacer3(),
              customButton(
                onTap: () {
                  _showPaymentBottomSheet(context, "Subscribe");
                },
                text: "Subscribe",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
