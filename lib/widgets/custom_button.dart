import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

Widget customButton({String? text, onTap, double? width}) {
  return GestureDetector(
    onTap: onTap ?? () {},
    child: Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: secondaryColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text ?? "",
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}
