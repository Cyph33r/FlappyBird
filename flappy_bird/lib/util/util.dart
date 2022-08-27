import 'package:flutter/foundation.dart';

enum Direction { upToDown, downToUp }

extension DoubleUtil on double {
  double constrain(
    double lower,
    double upper,
  ) {
    if (upper < lower) {
      throw ArgumentError("Upper limit is greater than lower limit");
    }
    if (this > upper) {
      return upper;
    } else if (this < lower) {
      return lower;
    }
    return this;
  }

  double convertToAlignment(double screenWidth) {
    final middle = screenWidth / 2;
    var toReturn = 0.0;
    if (this == middle) toReturn = 0;
    if (this > middle) toReturn = (this - middle) / middle;
    if (this < middle) toReturn = -1 + (this / middle);
    return toReturn;
  }

  bool inRange(double lower, double upper) => lower <= this && this <= upper;
}
