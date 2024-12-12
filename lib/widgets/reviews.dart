import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';

class ReviewBottomSheet extends StatefulWidget {
  final double rating;
  final List<Map<String, dynamic>> reviews;

  const ReviewBottomSheet({
    super.key,
    required this.rating,
    this.reviews = const [],
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
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
          // Top bar indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: mutedTextColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product reviews heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeadingText('Product reviews'),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          ParagraphText(widget.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                  spacer(),
                  // Intro text
                  ParagraphText(
                    'See what other people say about this product',
                    color: mutedTextColor,
                  ),
                  spacer1(),
                  // Reviews list
                  if (widget.reviews.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.separated(
                        itemCount: widget.reviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final review = widget.reviews[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with initials
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
                              // Name and comment
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ParagraphText(
                                      review['name'] ?? '',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    spacer(),
                                    ParagraphText(review['comment'] ?? ''),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Star rating
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
                  // Leave review
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: primaryColor, width: 1.0),
                      ),
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
                  // Review input field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: reviewController,
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
                          onTap: () {
                            if (selectedRating > 0 &&
                                reviewController.text.isNotEmpty) {
                              Navigator.pop(context, {
                                'rating': selectedRating,
                                'comment': reviewController.text,
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please add both rating and review'),
                                ),
                              );
                            }
                          },
                          text: "Submit",
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
