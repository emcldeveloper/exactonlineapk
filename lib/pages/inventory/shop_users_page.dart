import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/widgets/invite_user_dialog.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:hugeicons/hugeicons.dart';

class ShopUsersPage extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopUsersPage({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  @override
  State<ShopUsersPage> createState() => _ShopUsersPageState();
}

class _ShopUsersPageState extends State<ShopUsersPage> {
  final UsersControllers usersController = Get.put(UsersControllers());
  bool _isLoading = true;
  List<dynamic> shopUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchShopUsers();
  }

  Future<void> _fetchShopUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await usersController.getShopUsers(widget.shopId);
      setState(() {
        shopUsers = users ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Error",
        "Failed to load shop users: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCancel02,
          color: Colors.white,
        ),
      );
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              spacer2(),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      (user['name'] ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user['status'] == 'active'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['status'] ?? 'pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: user['status'] == 'active'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              spacer2(),
              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: user['phone'] ?? 'N/A',
              ),
              _buildDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: user['email'] ?? 'N/A',
              ),
              spacer2(),
              ParagraphText(
                'Permissions',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              spacer1(),
              _buildPermissionCard(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                label: 'POS Access',
                hasAccess: user['hasPOSAccess'] ?? false,
              ),
              spacer1(),
              _buildPermissionCard(
                icon: HugeIcons.strokeRoundedPackage,
                label: 'Inventory Access',
                hasAccess: user['hasInventoryAccess'] ?? false,
              ),
              spacer2(),
              if (user['status'] == 'pending') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _resendInvitation(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  label: const Text(
                    'Resend Invitation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                spacer1(),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  _confirmRemoveUser(user);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                label: const Text(
                  'Remove User',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String label,
    required bool hasAccess,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasAccess ? primary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasAccess ? primary.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            color: hasAccess ? primary : Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasAccess ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
          Icon(
            hasAccess ? Icons.check_circle : Icons.cancel,
            color: hasAccess ? Colors.green : Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _resendInvitation(Map<String, dynamic> user) {
    Get.snackbar(
      "Invitation Sent",
      "Invitation resent to ${user['name']}",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedTick01,
        color: Colors.white,
      ),
    );
  }

  void _confirmRemoveUser(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Text("Remove User"),
        content: Text(
          "Are you sure you want to remove ${user['name']} from your shop?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _removeUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeUser(Map<String, dynamic> user) async {
    try {
      await usersController.removeShopUser(widget.shopId, user['id']);
      Get.snackbar(
        "Success",
        "${user['name']} has been removed",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedTick01,
          color: Colors.white,
        ),
      );
      _fetchShopUsers(); // Refresh the list
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to remove user: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCancel02,
          color: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.shopName,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invite users to manage your shop',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          showInviteUserDialog(
                            context: context,
                            shopId: widget.shopId,
                            onInviteSent: _fetchShopUsers,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          'Invite User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchShopUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: shopUsers.length,
                    itemBuilder: (context, index) {
                      final user = shopUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
      floatingActionButton: shopUsers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                showInviteUserDialog(
                  context: context,
                  shopId: widget.shopId,
                  onInviteSent: _fetchShopUsers,
                );
              },
              backgroundColor: primary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Invite User',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userName = user['name'] ?? 'Unknown User';
    final userPhone = user['phone'] ?? 'N/A';
    final userStatus = user['status'] ?? 'pending';
    final hasPOSAccess = user['hasPOSAccess'] ?? false;
    final hasInventoryAccess = user['hasInventoryAccess'] ?? false;

    return GestureDetector(
      onTap: () => _showUserDetails(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primary.withOpacity(0.1),
              child: Text(
                userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: userStatus == 'active'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: userStatus == 'active'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userPhone,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hasPOSAccess) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedShoppingCart01,
                                color: primary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'POS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (hasInventoryAccess)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedPackage,
                                color: primary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Inventory',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
