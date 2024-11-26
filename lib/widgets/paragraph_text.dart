import 'package:flutter/material.dart';

Widget ParagraphText(
  String text, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  TextDecoration? decoration,
}) {
  return Text(
    text,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
      fontWeight: fontWeight ?? FontWeight.normal,
      fontSize: fontSize ?? 12,
      color: color ?? Colors.black,
      decoration: decoration,
    ),
  );
}
