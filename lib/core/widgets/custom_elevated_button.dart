import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String label;
  final Color? backgroundColor;
  final double? radius;
  final void Function() onTap;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    this.prefixIcon,
    this.textStyle,
    this.backgroundColor,
    this.radius,
    this.suffixIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1000.r),
        ),
        backgroundColor: backgroundColor ?? ColorManager.blue,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: textStyle ??
            getMediumStyle(color: ColorManager.white)
                .copyWith(fontSize: FontSize.s20),
      ),
    );
  }
}
