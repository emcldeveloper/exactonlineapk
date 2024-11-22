import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterAsSellerPage extends StatelessWidget {
  const RegisterAsSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
         appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: secondaryColor,
              ),
            )),
        title: ParagraphText("Register your business"),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Business Name"),
                labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                border: OutlineInputBorder(),
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
                hintText: "Enter business name",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer(),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Business Phone number"),
                labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                border: OutlineInputBorder(),
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
                hintText: "Enter phone number",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer(),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Business Address"),
                labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                border: OutlineInputBorder(),
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
                hintText: "Enter business address",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer(),
            TextFormField(
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                label: Text("Short Description"),
                labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                border: OutlineInputBorder(),
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
                hintText: "Write short business description",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer3(),
            customButton(
                onTap: () {
                  Get.to(() => HomePage());
                },
                text: "Submit Details"),
        
          ],
        ),
      ),
    );
  }
}
