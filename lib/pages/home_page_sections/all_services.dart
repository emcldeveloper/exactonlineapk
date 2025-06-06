import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AllServices extends StatefulWidget {
  const AllServices({super.key});

  @override
  State<AllServices> createState() => _AllServicesState();
}

class _AllServicesState extends State<AllServices>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TabController _tabController;
  final TextEditingController keywordController = TextEditingController();
  final RxList<dynamic> services = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasMore = true.obs;
  final RxList<dynamic> categories = <dynamic>[].obs;
  final RxInt currentTabIndex = 0.obs;
  final RxBool isSearching = false.obs;

  static const int _limit = 50;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeCategories();
    _scrollController.addListener(_onScroll);
    keywordController.addListener(_onSearchChanged);
  }

  Future<void> _initializeCategories() async {
    try {
      final res = await CategoriesController().getCategories(
        page: 1,
        limit: 50,
        type: "service",
        keyword: "",
      );
      categories.value = [
        {"id": "All", "name": "All"}
      ]..addAll(res);
      _tabController = TabController(
        length: categories.length,
        vsync: this,
      );
      _tabController.addListener(_handleTabChange);
      _fetchServices(1);
    } catch (e) {
      Get.snackbar("Error", "Failed to load categories: $e");
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (currentTabIndex.value != _tabController.index) {
      currentTabIndex.value = _tabController.index;
      _resetAndFetchServices();
    }
  }

  void _onSearchChanged() {
    _resetAndFetchServices();
  }

  @override
  void dispose() {
    keywordController.removeListener(_onSearchChanged);
    keywordController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _buildServiceGrid(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Obx(() => IconButton(
            icon: Icon(
              isSearching.value ? Icons.close : Icons.arrow_back_ios,
              color: mutedTextColor,
              size: 14.0,
            ),
            onPressed: () {
              if (isSearching.value) {
                isSearching.value = false;
                keywordController.clear();
              } else {
                Navigator.pop(context);
              }
            },
          )),
      title: Obx(() => isSearching.value
          ? TextField(
              controller: keywordController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search services...",
                border: InputBorder.none,
              ),
            )
          : HeadingText("Available Services")),
      centerTitle: true,
      actions: [
        Obx(() => !isSearching.value
            ? IconButton(
                icon: Icon(
                  AntDesign.search_outline,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  isSearching.value = true;
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  _resetAndFetchServices();
                },
              )),
        const SizedBox(width: 10),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _buildTabBar(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(() {
      if (categories.isEmpty) return const SizedBox.shrink();

      return TabBar(
        controller: _tabController,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        dividerColor: const Color.fromARGB(255, 234, 234, 234),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        labelPadding: const EdgeInsets.all(0),
        tabs: categories.map((category) => _buildTabItem(category)).toList(),
      );
    });
  }

  Widget _buildTabItem(dynamic category) {
    final int index = categories.indexOf(category);
    return Obx(() => Tab(
          child: Padding(
            padding: EdgeInsets.only(left: category["name"] == "All" ? 16 : 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color:
                    currentTabIndex.value == index ? primary : Colors.grey[100],
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Text(
                  category["name"],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: currentTabIndex.value == index
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildServiceGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : services.isEmpty
              ? noData()
              : StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 10,
                  children: [
                    ...services.map((service) => ServiceCard(
                          isStagger: true,
                          data: service,
                        )),
                    if (isLoading.value) ..._buildLoadingIndicators(),
                  ],
                )),
    );
  }

  List<Widget> _buildLoadingIndicators() {
    return [
      Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(color: Colors.black),
        ),
      ),
      Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(color: Colors.black),
        ),
      ),
    ];
  }

  Future<void> _fetchServices(int page) async {
    // if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    try {
      final categoryId = currentTabIndex.value == 0
          ? null
          : categories[currentTabIndex.value]["id"];

      final res = await ServiceController().getServices(
        page: page,
        limit: _limit,
        keyword: keywordController.text.trim(),
        category: categoryId,
      );

      final filteredRes =
          res.where((item) => item["ServiceImages"].isNotEmpty).toList();

      if (filteredRes.isEmpty || filteredRes.length < _limit) {
        hasMore.value = false;
      }

      if (page == 1) {
        services.value = filteredRes;
      } else {
        services.addAll(filteredRes);
      }
    } catch (e) {
      Get.snackbar("Error", "Error loading services: $e");
    } finally {
      print("Finished loading");
      isLoading.value = false;
    }
  }

  void _resetAndFetchServices() {
    _currentPage = 1;
    hasMore.value = true;
    services.clear();
    _fetchServices(_currentPage);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !isLoading.value &&
        hasMore.value) {
      _currentPage++;
      _fetchServices(_currentPage);
    }
  }
}
