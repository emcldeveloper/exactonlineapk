import 'package:flutter/material.dart';

Widget ParagraphText(text, {fontSize, fontWeight, color, textAlign}) {
   return Text(
    text,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.bold,
        fontSize: fontSize ?? 12,
        color: color ?? Colors.black),
  );
}
