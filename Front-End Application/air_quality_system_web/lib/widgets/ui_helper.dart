import 'dart:core';

/// ui standard
final scale = 0 ;
final standardWidth = 375.0 + scale;
final standardHeight = 815.0 + scale;
// final standardHeight = (standardWidth * 815) / 375;

/// late init
double screenWidth;
double screenHeight;

/// scale [height] by [standardHeight]
double realH(double height) {
  assert(screenHeight != 0.0);
  return height / standardHeight * screenHeight;
}

// scale [width] by [ standardWidth ]
double realW(double width) {
  assert(screenWidth != 0.0);
  return width / standardWidth * screenWidth;
}
