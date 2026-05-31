import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    required this.onTap,
    required this.buttonText,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  final void Function()? onTap;
  final String buttonText;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Text(buttonText),
        ),
      ),
    );
  }
}
