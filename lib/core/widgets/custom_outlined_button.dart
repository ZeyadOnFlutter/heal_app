import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';

class CustomOutlinedButton extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String label;
  final Color? backgroundColor;
  final double? radius;
  final void Function() onTap;
  final TextStyle? textStyle;

  const CustomOutlinedButton({
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
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
        side: const BorderSide(color: ColorManager.grey2),
      ),
      onPressed: onTap,
      label: Text(
        label,
        style: textStyle ??
            getRegularStyle(color: ColorManager.black)
                .copyWith(fontSize: FontSize.s16),
      ),
      icon: prefixIcon,
    );
  }
}
