import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

Widget customButton({
  String? text,
  required VoidCallback onTap,
  double? width,
  double? vertical,
  Color? buttonColor,
  Color? textColor,
  double? rounded,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rounded ?? 30.0),
        color: buttonColor ?? secondaryColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vertical ?? 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text ?? "",
              style: TextStyle(
                color: textColor ?? primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
