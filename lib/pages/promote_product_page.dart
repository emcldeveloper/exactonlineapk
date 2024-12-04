import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/payment_method.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoteProductPage extends StatefulWidget {
  final Map<dynamic, dynamic> productData;

  const PromoteProductPage({required this.productData, Key? key})
      : super(key: key);

  @override
  State<PromoteProductPage> createState() => _PromoteProductPageState();
}

class _PromoteProductPageState extends State<PromoteProductPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? current) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
        if (controller == _startDateController) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _showPaymentBottomSheet() {
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
        child: PaymentMethodBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Product Details"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/shortsleeves.png",
                  height: 430,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParagraphText(
                          widget.productData['title'] ?? '',
                          fontWeight: FontWeight.bold,
                        ),
                        ParagraphText(
                          widget.productData['price'] ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              spacer1(),
              Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ParagraphText(
                        "Promotion Budget",
                        fontWeight: FontWeight.bold,
                        color: mutedTextColor,
                      ),
                      HeadingText(
                        "TZS 250,000",
                      ),
                    ],
                  ),
                ),
              ),
              spacer1(),
              ParagraphText(
                "Start Date",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () =>
                    _selectDate(context, _startDateController, _startDate),
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  hintText: "Select a date",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: mutedTextColor,
                    size: 16.0,
                  ),
                ),
              ),
              spacer1(),
              ParagraphText(
                "End Date",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController, _endDate),
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  hintText: "Select a date",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: mutedTextColor,
                    size: 16.0,
                  ),
                ),
              ),
              spacer1(),
              customButton(
                onTap: _showPaymentBottomSheet,
                text: "Pay to Promote",
              ),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }
}
