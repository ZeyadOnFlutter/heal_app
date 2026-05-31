import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/font_manager.dart';
import '../../../../core/resources/styles_manager.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.label1, this.label2});
  final String? label1;
  final String? label2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 5.h),
        if (label1?.isNotEmpty ?? false)
          Text(
            label2!,
            style: getMediumStyle(color: ColorManager.black).copyWith(fontSize: FontSize.s28),
            textAlign: TextAlign.center,
          ),
        if ((label1?.isNotEmpty ?? false) && (label2?.isNotEmpty ?? false)) SizedBox(height: 8.h),
        if (label2?.isNotEmpty ?? false)
          Text(
            label1!,
            style: getRegularStyle(color: ColorManager.grey).copyWith(fontSize: FontSize.s12),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
