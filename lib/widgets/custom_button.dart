import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

Widget customButton({
  String? text,
  required VoidCallback onTap,
  double? width,
  double? vertical,
  Color? buttonColor,
  Color? textColor,
  bool loading = false,
  double? rounded,
  Widget? child,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rounded ?? 30.0),
        color: buttonColor ?? Colors.black,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vertical ?? 18.0),
        child: loading
            ? Center(
                child: Container(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ))
            : Center(
                child: Text(
                  text ?? "",
                  style: TextStyle(
                    color: textColor ?? primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    ),
  );
}
