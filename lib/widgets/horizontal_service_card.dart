import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/controllers/cart_services_controller.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:get/get.dart';

class HorizontalServiceCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onDelete;
  final Function? onRefresh;
  final bool isOrder;
  final Map<String, dynamic>? order;

  const HorizontalServiceCard({
    super.key,
    required this.data,
    this.order,
    this.onRefresh,
    this.isOrder = false,
    this.onDelete,
  });

  @override
  State<HorizontalServiceCard> createState() => _HorizontalServiceCardState();
}

class _HorizontalServiceCardState extends State<HorizontalServiceCard> {
  late int currentIndex;
  CartServicesController cartServicesController =
      Get.put(CartServicesController());

  @override
  void initState() {
    super.initState();
    print("Service data: ${widget.data}");
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: widget.data["Service"]?["ServiceImages"] != null &&
                        widget.data["Service"]["ServiceImages"].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.data["Service"]["ServiceImages"][0]
                            ["image"],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.business,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: Colors.grey[400],
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Text(
                    widget.data["Service"]?["name"] ?? "Unknown Service",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Package Type
                  if (widget.data["packageType"] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.data["packageType"].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Service Description (if available)
                  if (widget.data["Service"]?["description"] != null)
                    Text(
                      widget.data["Service"]["description"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // Price and Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        "TZS ${toMoneyFormmat(widget.data["price"]?.toString() ?? "0")}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Delete Button (only show if not an order)
                      if (!widget.isOrder)
                        GestureDetector(
                          onTap: () {
                            showPopupAlert(
                              context,
                              iconAsset: "assets/images/delete.png",
                              heading: "Remove Service",
                              text:
                                  "Are you sure you want to remove this service from your cart?",
                              button1Text: "Cancel",
                              button1Action: () {
                                Navigator.of(context).pop();
                              },
                              button2Text: "Remove",
                              button2Action: () async {
                                try {
                                  await cartServicesController
                                      .deleteCartService(
                                    widget.data["id"].toString(),
                                  );
                                  Navigator.of(context).pop();
                                  if (widget.onRefresh != null) {
                                    widget.onRefresh!();
                                  }
                                  Get.snackbar(
                                      "Success", "Service removed from cart");
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  Get.snackbar(
                                      "Error", "Failed to remove service");
                                }
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
