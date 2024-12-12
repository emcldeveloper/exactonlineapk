import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/active_business_selection.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class SettingMyshopPage extends StatelessWidget {
  const SettingMyshopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shopList = [
      {"name": "Vunjabei shop", "createdAt": "created at 28/10/2024"},
      {"name": "Bamba shop", "createdAt": "created at 27/10/2024"},
      {"name": "Niko shop", "createdAt": "created at 26/10/2024"},
    ];

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

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: ParagraphText(
          "Settings",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        "Change",
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingText(
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
                  InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.edit,
                      color: mutedTextColor,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            spacer1(),
            customButton(
              onTap: () {},
              text: "Delete Business",
              vertical: 8.0,
              textColor: Colors.red[800],
              buttonColor: Colors.red[50],
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
                const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24.0,
                ),
                const SizedBox(width: 8),
              ],
            ),
            spacer1(),
            Expanded(
              child: ListView.builder(
                itemCount: shopList.length,
                itemBuilder: (context, index) {
                  final shop = shopList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Icon(
                          Icons.arrow_forward_ios,
                          color: mutedTextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
