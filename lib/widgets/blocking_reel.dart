import 'package:flutter/material.dart';


Widget BlockingReel() {
  return Positioned(
    top: 40,
    right: 16,
    child: GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          Icons.more_vert_sharp,
          color: Colors.white,
        ),
      ),
    ),
  );
}
//  Container(
//                     width: 50.0,
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                             Icon(
//                               Icons.lock_outline,
//                               size: 16,
//                               color: Colors.black,
//                             ),
//                             SizedBox(width: 4),
//                             ParagraphText(
//                               'Block this reel',
//                             ),
//                           ],
//                         ),
//           );
         