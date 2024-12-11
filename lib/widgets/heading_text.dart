import 'package:flutter/material.dart';

Widget HeadingText(text, {fontWeight, fontSize, color, textAlign}) {
  return Text(
    text,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.w900,
        fontSize: fontSize ?? 19,
        color: color ?? Colors.black),
  );
}
