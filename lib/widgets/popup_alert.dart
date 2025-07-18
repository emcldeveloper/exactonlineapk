import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class PopupAlert extends StatelessWidget {
  final String iconAsset;
  final String heading;
  final String text;
  final String button1Text;
  final VoidCallback button1Action;
  final String button2Text;
  final VoidCallback button2Action;

  const PopupAlert({
    super.key,
    required this.iconAsset,
    required this.heading,
    required this.text,
    required this.button1Text,
    required this.button1Action,
    required this.button2Text,
    required this.button2Action,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: mainColor,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            iconAsset,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 40),
          ),
          spacer1(),
          HeadingText(
            heading,
            textAlign: TextAlign.center,
          ),
          spacer(),
          ParagraphText(
            text,
            textAlign: TextAlign.center,
          ),
          spacer1(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 5,
            children: [
              Expanded(
                child: customButton(
                  vertical: 10,
                  onTap: button1Action,
                  text: button1Text,
                  textColor: Colors.black,
                  buttonColor: primaryColor,
                ),
              ),
              Expanded(
                child: customButton(
                  vertical: 10,
                  onTap: button2Action,
                  text: button2Text,
                  buttonColor: secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showPopupAlert(
  BuildContext context, {
  required String iconAsset,
  required String heading,
  required String text,
  required String button1Text,
  required VoidCallback button1Action,
  required String button2Text,
  required VoidCallback button2Action,
}) {
  showDialog(
    context: context,
    builder: (context) => PopupAlert(
      iconAsset: iconAsset,
      heading: heading,
      text: text,
      button1Text: button1Text,
      button1Action: button1Action,
      button2Text: button2Text,
      button2Action: button2Action,
    ),
  );
}
