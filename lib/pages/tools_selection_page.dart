import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/pages/inventory/inventory_shop_selection_page.dart';
import 'package:e_online/pages/pos/pos_shop_selection_page.dart';
import 'package:e_online/constants/colors.dart';

class ToolsSelectionPage extends StatelessWidget {
  const ToolsSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: const Image(
                          image: AssetImage('assets/images/logo.png'),
                          height: 80),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to ExactOnline',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose your business tool',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Tools Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListView(
                    children: [
                      _buildToolCard(
                        context: context,
                        title: 'Shopping Center',
                        subtitle: 'Browse and shop products online',
                        icon: Icons.shopping_cart,
                        color: primary,
                        gradient: [primary.withOpacity(0.95), primary],
                        onTap: () {
                          // Navigate to shopping center (main page)
                          Get.to(() => const MainPage());
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildToolCard(
                        context: context,
                        title: 'Inventory Management',
                        subtitle: 'Manage products, stock, and alerts',
                        icon: Icons.inventory_2,
                        color: primary,
                        gradient: [primary.withOpacity(0.95), primary],
                        onTap: () {
                          // Navigate to inventory
                          Get.to(() => const InventoryShopSelectionPage());
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildToolCard(
                        context: context,
                        title: 'Point of Sale (POS)',
                        subtitle: 'Record sales and track analytics',
                        icon: Icons.point_of_sale,
                        color: primary,
                        gradient: [primary.withOpacity(0.95), primary],
                        onTap: () {
                          // Navigate to POS
                          Get.to(() => const POSShopSelectionPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
