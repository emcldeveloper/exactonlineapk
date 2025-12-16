import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:hugeicons/hugeicons.dart';

class InviteUserDialog extends StatefulWidget {
  final String shopId;
  final VoidCallback? onInviteSent;

  const InviteUserDialog({
    Key? key,
    required this.shopId,
    this.onInviteSent,
  }) : super(key: key);

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _hasInventoryAccess = false;
  bool _hasPOSAccess = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasInventoryAccess && !_hasPOSAccess) {
      Get.snackbar(
        "Error",
        "Please select at least one access type (POS or Inventory)",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCancel02,
          color: Colors.white,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UsersControllers usersController = Get.put(UsersControllers());

      final payload = {
        "shopId": widget.shopId,
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "hasInventoryAccess": _hasInventoryAccess,
        "hasPOSAccess": _hasPOSAccess,
      };

      await usersController.inviteUser(payload);

      setState(() {
        _isLoading = false;
      });

      Get.back(); // Close the dialog

      Get.snackbar(
        "Success",
        "Invitation sent successfully to ${_nameController.text}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedTick01,
          color: Colors.white,
        ),
      );

      if (widget.onInviteSent != null) {
        widget.onInviteSent!();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Failed to send invitation: ${e.toString()}",
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
    return Dialog(
      backgroundColor: mainColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invite User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                spacer1(),
                ParagraphText(
                  'Send an invitation to a new user to access your system',
                  color: mutedTextColor,
                  fontSize: 13,
                ),
                spacer2(),

                // Name Field
                TextForm(
                  label: 'Full Name',
                  hint: 'Enter user\'s full name',
                  textEditingController: _nameController,
                  textInputType: TextInputType.name,
                  withValidation: true,
                ),

                // Phone Number Field
                TextForm(
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  textEditingController: _phoneController,
                  textInputType: TextInputType.phone,
                  withValidation: true,
                ),

                spacer1(),
                ParagraphText(
                  'Access Permissions',
                  fontWeight: FontWeight.bold,
                ),
                spacer(),
                ParagraphText(
                  'Select what the user can access',
                  color: mutedTextColor,
                  fontSize: 12,
                ),
                spacer1(),

                // Access Checkboxes
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedShoppingCart01,
                              color: primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'POS (Point of Sale)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Allow user to make sales and process orders',
                          style: TextStyle(
                            fontSize: 11,
                            color: mutedTextColor,
                          ),
                        ),
                        value: _hasPOSAccess,
                        onChanged: (value) {
                          setState(() {
                            _hasPOSAccess = value ?? false;
                          });
                        },
                        activeColor: primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      Divider(color: Colors.grey.shade300, height: 1),
                      CheckboxListTile(
                        title: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedPackage,
                              color: primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Inventory Management',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Allow user to manage products and stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: mutedTextColor,
                          ),
                        ),
                        value: _hasInventoryAccess,
                        onChanged: (value) {
                          setState(() {
                            _hasInventoryAccess = value ?? false;
                          });
                        },
                        activeColor: primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                spacer2(),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendInvitation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Send Invite',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show the invite dialog
void showInviteUserDialog({
  required BuildContext context,
  required String shopId,
  VoidCallback? onInviteSent,
}) {
  showDialog(
    context: context,
    builder: (context) => InviteUserDialog(
      shopId: shopId,
      onInviteSent: onInviteSent,
    ),
  );
}
