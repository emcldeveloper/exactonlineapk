import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderProductsForCustomerPage extends StatelessWidget {
  const OrderProductsForCustomerPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final List<Map<String, dynamic>> orderItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/teal_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/red_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/black_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/green_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
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
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("Order #0001"),
        centerTitle: true,
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
            children: [
              Column(
                children: orderItems.map((item) {
                  return HorizontalProductCard(data: item);
                }).toList(),
              ),
              spacer2(),
              spacer1(),
              customButton(
                onTap: () {
                  //  analytics.logEvent(
                  //           name: 'call_seller',
                  //           parameters: {'seller_id': shopId, 'shopName': shopName, 'shopPhone': shopPhone, 'from_page': 'OrderProductsForCustomerPage' },
                  //         );
                },
                text: "Call Seller",
              ),
              spacer(),
              customButton(
                onTap: () {
                    //  analytics.logEvent(
                    //         name: 'chat_seller',
                    //         parameters: {
                    //           'seller_id': shopId,
                    //           'shopName': shopName,
                    //           'shopPhone': shopPhone,
                    //           'from_page': 'OrderProductsForCustomerPage'
                    //         },
                    //       );
                },
                text: "Chat with Seller",
                buttonColor: mutedTextColor,
                textColor: primaryColor,
              ),
              spacer3(),
            ],
          ),
        ),
      ),
    );
  }
}
