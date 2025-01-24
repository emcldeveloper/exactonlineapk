// ignore_for_file: non_constant_identifier_names
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

Widget TextForm(
    {hint,
    key,
    TextEditingController? textEditingController,
    initialValue,
    TextInputType? textInputType,
    color,
    Function(String)? onChanged,
    label,
    withValidation = true,
    isPassword = false,
    int? lines,
    suffixIcon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphText(
          label ?? "",
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          obscureText: isPassword,
          initialValue: initialValue,
          onChanged: onChanged ?? (value) {},
          keyboardType: textInputType ?? TextInputType.text,
          style: TextStyle(color: Colors.black),
          maxLines: lines ?? 1,
          validator: (value) {
            if (withValidation) {
              if (value == "") {
                return "Field required";
              }
              return null;
            } else {}
          },
          controller: textEditingController,
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
