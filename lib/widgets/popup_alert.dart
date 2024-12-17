import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';

class PopupAlert extends StatelessWidget {
  final IconData icon;
  final String heading;
  final String text;
  final String button1Text;
  final VoidCallback button1Action;
  final String button2Text;
  final VoidCallback button2Action;

  const PopupAlert({
    Key? key,
    required this.icon,
    required this.heading,
    required this.text,
    required this.button1Text,
    required this.button1Action,
    required this.button2Text,
    required this.button2Action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: HeadingText(
              heading,
            ),
          ),
        ],
      ),
      content: ParagraphText(
        text,
      ),
      actions: [
        customButton(
          onTap: () {
            button1Action();
          },
          text: button1Text,
          buttonColor: mainColor,
        ),
        customButton(
          onTap: () {
            button2Action();
          },
          text: button2Text,
          buttonColor: secondaryColor,
        )
      ],
    );
  }
}

void showPopupAlert(
  BuildContext context, {
  required IconData icon,
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
      icon: icon,
      heading: heading,
      text: text,
      button1Text: button1Text,
      button1Action: button1Action,
      button2Text: button2Text,
      button2Action: button2Action,
    ),
  );
}
