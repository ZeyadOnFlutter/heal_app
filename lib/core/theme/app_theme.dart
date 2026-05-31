import 'package:flutter/material.dart';

import '../resources/color_manager.dart';

final ThemeData appTheme = ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  scaffoldBackgroundColor: ColorManager.lightGrey,
);
