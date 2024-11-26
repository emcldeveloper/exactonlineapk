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
    Key? key,
    required this.rating,
    this.reviews = const [],
  }) : super(key: key);

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
                          HeadingText(widget.rating.toStringAsFixed(1)),
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.reviews.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final review = widget.reviews[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar with initials
                            CircleAvatar(
                              child: ParagraphText(
                                review['name']?.substring(0, 2).toUpperCase() ?? 'NA',
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
                  spacer1(),
                  // Leave review
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText(
                              'Leave your review',
                              fontWeight: FontWeight.bold,
                            ),
                            ParagraphText(
                              'Rate this product',
                              color: mutedTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.star,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : Colors.grey[300],
                            ),
                            onPressed: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
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
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      customButton(
                        onTap: () {
                          if (selectedRating > 0 && reviewController.text.isNotEmpty) {
                            // Handle review submission here
                            // You can add the review to your reviews list or send it to an API
                            Navigator.pop(context, {
                              'rating': selectedRating,
                              'comment': reviewController.text,
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add both rating and review'),
                              ),
                            );
                          }
                        },
                        text: "Submit",
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