import 'package:flutter/material.dart';

Widget HeadingText(text, {fontWeight, fontSize, color, textAlign}) {
  return Text(
    '$text',
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.w900,
        fontSize: fontSize != null ? double.parse(fontSize.toString()) : 20,
        color: color ?? Colors.black),
  );
}
