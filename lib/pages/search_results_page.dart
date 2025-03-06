import 'package:e_online/constants/colors.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Full list of products
  final List<Map<String, dynamic>> allResults = [
    {
      'id': 21,
      'title': "J.Crew T-shirt",
      'price': "25,000 TSH",
      'imageUrl': [
        "assets/images/whiteTop.png",
        "assets/products/product1.jpg",
        "assets/products/product1.jpg",
        "assets/products/product1.jpg",
      ],
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
      'category': "clothes",
      'size': "2xl",
      'color': "Black",
      'shipping': "Free Shipping",
      'type': "ad",
    },
    {
      'title': "Blue T-shirt",
      'price': "30,000 TSH",
      'imageUrl': ["assets/images/blueTop.png"],
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
    {
      'title': "Maroon T-shirt",
      'price': "20,000 TSH",
      'imageUrl': ["assets/images/maroonTop.png"],
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
    {
      'title': "Peach T-shirt",
      'price': "25,000 TSH",
      'imageUrl': ["assets/images/peachTop.png"],
      'description':
          "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
      'rating': 4.5,
    },
  ];

  // Filtered results based on search query
  List<Map<String, dynamic>> filteredResults = [];

  // Search query text
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    trackScreenView("SearchResultsPage");
    // Initially show all results
    filteredResults = allResults;
  }

  // Function to filter results based on the search query
  void updateSearchResults(String query) {
    setState(() {
      searchQuery = query;
      if (searchQuery.isEmpty) {
        // Show all results if search query is empty
        filteredResults = allResults;
      } else {
        filteredResults = allResults.where((item) {
          final title = item['title'].toString().toLowerCase();
          final description = item['description'].toString().toLowerCase();
          final searchLower = searchQuery.toLowerCase();
          return title.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }
    });
  }

  // Build search bar with onChanged callback
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
                onChanged: (value) => updateSearchResults(value),
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
              // Trigger search manually if needed (optional)
              updateSearchResults(searchQuery);
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Colors.white,
                size: 22.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: mutedTextColor,
              size: 16.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: buildSearchBar(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color.fromARGB(255, 242, 242, 242),
              height: 1.0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              spacer(),
              const FilterTilesWidget(),
              spacer(),
              // Display filtered results
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final item = filteredResults[index];
                  return FavoriteCard(data: item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
