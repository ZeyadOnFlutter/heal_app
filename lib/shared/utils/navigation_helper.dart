import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static PageRoute<T> createRoute<T extends Object?>(Widget page) {
    return Platform.isIOS
        ? CupertinoPageRoute<T>(builder: (_) => page)
        : MaterialPageRoute<T>(builder: (_) => page);
  }
}