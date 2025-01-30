import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

class ActiveBusinessSelection extends StatefulWidget {
  const ActiveBusinessSelection({super.key});

  @override
  State<ActiveBusinessSelection> createState() =>
      _ActiveBusinessSelectionState();
}

class _ActiveBusinessSelectionState extends State<ActiveBusinessSelection> {
  final UserController userController = Get.find();

  String? selectedBusiness;

  List<dynamic> shopList = [];

  @override
  void initState() {
    super.initState();
    shopList = userController.user.value['Shops'] ?? [];
  }

  // final List<Map<String, String>> businesses = [
  //   {"name": "Business 1", "details": "Business 1 details"},
  //   {"name": "Business 2", "details": "Business 2 details"},
  //   {"name": "Business 3", "details": "Business 3 details"},
  // ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spacer1(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spacer1(),
            ParagraphText(
              "Select business",
              fontWeight: FontWeight.bold,
            ),
            spacer2(),
            ...shopList.map((business) {
              return Column(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: business['id']!,
                        groupValue: selectedBusiness,
                        onChanged: (value) {
                          setState(() {
                            selectedBusiness = value;
                          });
                        },
                        activeColor: secondaryColor,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText(
                              business['name']!,
                              fontWeight: FontWeight.bold,
                            ),
                            ParagraphText(
                              business['description']!,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  spacer1(),
                ],
              );
            }),
            spacer1(),
            customButton(
              onTap: () async {
                if (selectedBusiness != null) {
                  await SharedPreferencesUtil.saveSelectedBusiness(
                      selectedBusiness!);
                  Navigator.pop(context, selectedBusiness);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a business."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              text: "Save selection",
            ),
            spacer3(),
          ],
        ),
      ),
    );
  }
}
