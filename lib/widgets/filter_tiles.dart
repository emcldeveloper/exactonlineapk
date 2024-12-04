import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/filter_search.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

final List<Map<String, dynamic>> filters = [
  {
    'name': 'All',
  },
  {
    'name': 'Free delivery',
  },
  {
    'name': 'Top Sales',
  },
];

class FilterTilesWidget extends StatefulWidget {
  @override
  _FilterTilesWidgetState createState() => _FilterTilesWidgetState();
}

class _FilterTilesWidgetState extends State<FilterTilesWidget> {
  String selectedFilter = 'All';

  void callFilterSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FilterSearchBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ParagraphText("Filter", fontWeight: FontWeight.bold),
            GestureDetector(
              onTap: () {
                callFilterSearch(context);
              },
              child: const Icon(AntDesign.menu_fold_outline),
            ),
          ],
        ),
        spacer1(),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: filters.map((filter) {
            bool isSelected = filter['name'] == selectedFilter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter['name'];
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? Colors.black : primaryColor,
                ),
                child: ParagraphText(
                  filter['name'],
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
