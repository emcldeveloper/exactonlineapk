import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RelatedServices extends StatelessWidget {
  String? serviceId;
  RelatedServices({super.key, this.serviceId = ""});

  final RxList services = <dynamic>[].obs;
  final ScrollController _scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  final int _limit = 50;

  @override
  Widget build(BuildContext context) {
    _fetchServices(_currentPage);
    _scrollController.addListener(_onScroll);

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: services.isEmpty && !isLoading.value
            ? _buildShimmerGrid()
            : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    StaggeredGrid.count(
                      crossAxisCount: 2, // 2 items per row
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 12,
                      children: services
                          .map((service) => ServiceCard(
                                isStagger: true,
                                data: service,
                              ))
                          .toList(),
                    ),
                    if (isLoading.value) _buildLoadingIndicator(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 0,
      crossAxisSpacing: 12,
      children: List.generate(
        5,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 180, // Ensure consistent height
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CircularProgressIndicator(color: Colors.black),
    );
  }

  Future<void> _fetchServices(int page) async {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;
    try {
      final res = await ServiceController().getRelatedServices(
        serviceId: serviceId,
        page: page,
        limit: _limit,
        keyword: "",
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
      isLoading.value = false;
    }
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
