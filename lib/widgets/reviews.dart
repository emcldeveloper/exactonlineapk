import 'package:e_online/controllers/review_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:get/get.dart';

class ReviewBottomSheet extends StatefulWidget {
  final double rating;
  final String productId;
  final List<Map<String, dynamic>> reviews;

  const ReviewBottomSheet({
    super.key,
    required this.rating,
    required this.productId,
    this.reviews = const [],
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int selectedRating = 0;
  var isLoading = false.obs;
  final UserController userController = Get.find();
  final ReviewController reviewController = Get.put(ReviewController());
  final TextEditingController myReviewController = TextEditingController();
  double averageRating = 0.0;
  List<Map<String, dynamic>> allReviews = [];

  @override
  void initState() {
    super.initState();
    allReviews = List.from(widget.reviews);
    _calculateAverageRating();
  }

  @override
  void dispose() {
    myReviewController.dispose();
    super.dispose();
  }

  void _calculateAverageRating() {
    if (allReviews.isNotEmpty) {
      double sum =
          allReviews.fold(0, (acc, review) => acc + (review['rating'] ?? 0));
      setState(() {
        averageRating = sum / allReviews.length;
      });
    } else {
      setState(() {
        averageRating = widget.rating;
      });
    }
  }

  Future<void> _sendProductReview() async {
    if (selectedRating == 0 || myReviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a review.')),
      );
      return;
    }

    isLoading.value = true;
    var userId = userController.user.value['id'] ?? "";
    var newReview = {
      "ProductId": widget.productId,
      "UserId": userId,
      "rating": selectedRating,
      "description": myReviewController.text,
    };

    try {
      await reviewController.addReview(newReview);

      setState(() {
        allReviews.insert(0, {
          "name": "You",
          "description": myReviewController.text,
          "rating": selectedRating,
        });
        _calculateAverageRating();
        selectedRating = 0;
        myReviewController.clear();
      });

      isLoading.value = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint("Error sending product review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 228, 228, 228),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeadingText('Product reviews'),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 22.0),
                          const SizedBox(width: 4),
                          ParagraphText(averageRating
                              .toStringAsFixed(1)), // Dynamic average rating
                        ],
                      ),
                    ],
                  ),
                  spacer(),
                  ParagraphText(
                    'See what other people say about this product',
                    color: mutedTextColor,
                  ),
                  spacer1(),
                  if (allReviews.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.separated(
                        itemCount: allReviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final review = allReviews[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                child: ParagraphText(
                                  review['name']
                                          ?.substring(0, 2)
                                          .toUpperCase() ??
                                      'NA',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ParagraphText(
                                      review['name'] ?? '',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    spacer(),
                                    ParagraphText(review['description'] ?? ''),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: i < (review['rating'] ?? 0)
                                        ? Colors.amber
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  spacer1(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: primaryColor, width: 1.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ParagraphText(
                                  'Leave your review',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                                spacer(),
                                ParagraphText(
                                  'Rate this product',
                                  color: mutedTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: List.generate(
                              5,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRating = index + 1;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.star,
                                    color: index < selectedRating
                                        ? Colors.amber
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  spacer1(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: myReviewController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Write your review message here',
                            hintStyle: const TextStyle(fontSize: 12),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: customButton(
                          onTap: _sendProductReview,
                          text: isLoading.value ? null : "Submit",
                          child: isLoading.value
                              ? const CustomLoader(
                                  color: Colors.white,
                                  size: 15.0,
                                )
                              : null,
                          rounded: 15.0,
                        ),
                      ),
                    ],
                  ),
                  spacer1(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
