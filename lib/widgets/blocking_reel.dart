import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

class BlockingReel extends StatefulWidget {
  @override
  _BlockingReelWidgetState createState() => _BlockingReelWidgetState();
}

class _BlockingReelWidgetState extends State<BlockingReel> {
  bool isBlockContainerVisible = false;

  void toggleBlockContainer() {
    setState(() {
      isBlockContainerVisible = !isBlockContainerVisible;
    });
  }

  void blockReel() {
    // Add logic to block the reel here
    print('Reel blocked');
    // Hide the container after blocking
    setState(() {
      isBlockContainerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The BlockingReel button
        Positioned(
          top: 40,
          right: 16,
          child: GestureDetector(
            onTap: toggleBlockContainer,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.more_vert_sharp,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
        ),
        // The Block container
        if (isBlockContainerVisible)
          Positioned(
            top: 83,
            right: 16,
            child: GestureDetector(
              onTap: blockReel,
              child: Container(
                width: 150.0,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Block this reel',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
