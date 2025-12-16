// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';

Widget selectForm(
    {hint,
    key,
    TextEditingController? textEditingController,
    initialValue,
    TextInputType? textInputType,
    color,
    onChanged,
    label,
    List<DropdownMenuItem<String>>? items,
    validator,
    swahili,
    isPassword = false,
    int? lines,
    suffixIcon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphText(label ?? ""),
        const SizedBox(
          height: 5,
        ),
        DropdownButtonFormField(
          items: items ?? [],
          value: textEditingController!.text,
          onChanged: (value) {
            textEditingController.text = value.toString();
            if (onChanged != null) {
              onChanged(value);
            }
          },
          style: TextStyle(color: Colors.black),
          validator: validator ??
              (value) {
                if (value == "") {
                  return "Field required";
                }
                return null;
              },
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
