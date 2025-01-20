import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final Color color;

  const CustomLoader({
    Key? key,
    this.size = 20.0,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: size * 0.1, 
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
