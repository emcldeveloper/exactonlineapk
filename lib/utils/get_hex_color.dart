import 'dart:ui';

Color getHexColor(String letter) {
  if (letter.length != 1 ||
      !RegExp(r'^[A-Z]$', caseSensitive: false).hasMatch(letter)) {
    throw ArgumentError('Input must be a single letter A-Z.');
  }

  letter = letter.toUpperCase(); // Ensure uppercase
  int ascii = letter.codeUnitAt(0); // Get ASCII value

  // Generate consistent RGB values based on the ASCII value
  int r = (ascii * 7) % 256;
  int g = (ascii * 13) % 256;
  int b = (ascii * 17) % 256;

  // Combine RGB into a valid 0xFFRRGGBB format
  int colorValue = (0xFF << 24) | (r << 16) | (g << 8) | b;

  return Color(colorValue);
}
