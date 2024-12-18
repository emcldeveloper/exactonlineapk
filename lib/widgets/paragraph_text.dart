import 'package:flutter/material.dart';

Widget ParagraphText(
  String text, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  TextDecoration? decoration,
  int? maxLines,
  TextOverflow? overflow,
}) {
  return Text(
    text,
    textAlign: textAlign ?? TextAlign.start,
    maxLines: maxLines ?? 100,
    overflow: overflow ?? TextOverflow.visible,
    style: TextStyle(
      fontWeight: fontWeight ?? FontWeight.normal,
      fontSize: fontSize ?? 15,
      color: color ?? Colors.black,
      decoration: decoration,
    ),
  );
}
