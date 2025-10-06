import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopPasswordDialog extends StatefulWidget {
  final Map<String, dynamic> shopData;
  final VoidCallback onPasswordCorrect;

  const ShopPasswordDialog({
    Key? key,
    required this.shopData,
    required this.onPasswordCorrect,
  }) : super(key: key);

  @override
  _ShopPasswordDialogState createState() => _ShopPasswordDialogState();
}

class _ShopPasswordDialogState extends State<ShopPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final ShopController shopController = Get.find<ShopController>();
  bool _isLoading = false;
  String _errorMessage = '';
  int? _correctPassword;

  @override
  void initState() {
    super.initState();
    // Handle both int and string types from API
    final password = widget.shopData['password'];
    if (password is int) {
      _correctPassword = password;
    } else if (password is String) {
      _correctPassword = int.tryParse(password);
    } else {
      _correctPassword = null;
    }
  }

  void _verifyPassword() {
    final enteredPassword = _passwordController.text.trim();

    if (enteredPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the password';
      });
      return;
    }

    final enteredPasswordInt = int.tryParse(enteredPassword);
    if (enteredPasswordInt == null) {
      setState(() {
        _errorMessage = 'Password must be a number';
      });
      return;
    }

    if (enteredPasswordInt == _correctPassword) {
      // Password is correct
      Navigator.of(context).pop();
      widget.onPasswordCorrect();
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  void _forgotPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response =
          await shopController.resetShopPassword(widget.shopData['id']);
      print(response);
      if (response != null && response['status'] == true) {
        // Update the correct password with the new one
        final newPassword = response['body']['password'];
        setState(() {
          if (newPassword is int) {
            _correctPassword = newPassword;
          } else if (newPassword is String) {
            _correctPassword = int.tryParse(newPassword);
          }
        });

        Get.snackbar(
          "Password Reset",
          "New password sent to ${widget.shopData['phone']}. Please enter the new password.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to reset password. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: mainColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        'Shop Password Required',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This shop is password protected. Please enter the password to continue.',
              style: TextStyle(color: mutedTextColor),
            ),
            spacer1(),
            TextForm(
              textEditingController: _passwordController,
              label: "Shop Password",
              isPassword: true,
              hint: "Enter shop password",
              textInputType: TextInputType.number,
            ),
            if (_errorMessage.isNotEmpty) ...[
              Text(
                _errorMessage,
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(
              height: 8,
            ),
            // Enter button - full width at top
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Enter',
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            spacer1(),
            // Cancel and Forgot Password buttons - centered
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.back(); // Go back to previous page
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: mutedTextColor),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: _isLoading ? null : _forgotPassword,
                  child: Text(
                    'Forgot Password ?',
                    style:
                        TextStyle(color: primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
