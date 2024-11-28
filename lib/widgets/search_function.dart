import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

Widget buildSearchBar() {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search product here",
                hintStyle: TextStyle(color: mutedTextColor, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Perform search action
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.search, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
  );
}
