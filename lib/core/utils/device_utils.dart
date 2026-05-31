import 'package:flutter/material.dart';

extension DeviceUtils on BuildContext {
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
}
