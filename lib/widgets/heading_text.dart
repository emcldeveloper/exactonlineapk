import 'package:flutter/material.dart';

Widget HeadingText(text, {fontWeight, fontSize, color, textAlign }) {
  return Text(
    text,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.bold,
        fontSize: fontSize ?? 16,
        color: color ?? Colors.black),
  );
}
