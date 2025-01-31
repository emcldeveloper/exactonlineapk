import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

Widget buildSearchBar({Function(String)? onChanged}) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged ?? (value) {},
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              hintText: "Search here",
              hintStyle: TextStyle(color: mutedTextColor, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Perform search action
          },
          child: Container(
            height: 25,
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
  );
}
