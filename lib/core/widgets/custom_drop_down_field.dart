import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';
import '../resources/values_manager.dart';

class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.borderColor,
    this.cursorColor,
    super.key,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final String? prefixIcon;
  final Color? borderColor;
  final Color? cursorColor;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.s14,
          vertical: Insets.s18,
        ),
        hintText: widget.hintText ?? '',
        hintStyle:
            getMediumStyle(color: ColorManager.grey, fontSize: FontSize.s14),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: EdgeInsets.all(12.r),
                child: SvgPicture.asset(
                  widget.prefixIcon!,
                  fit: BoxFit.scaleDown,
                ),
              )
            : null,
        enabledBorder: _buildOutlinedBorder(widget.borderColor),
        focusedBorder: _buildOutlinedBorder(ColorManager.blue),
        border: _buildOutlinedBorder(widget.borderColor),
        errorMaxLines: 2,
      ),
      style: getMediumStyle(color: ColorManager.black, fontSize: FontSize.s14),
      iconEnabledColor: widget.cursorColor ?? ColorManager.blue,
      iconSize: 24.sp,
      dropdownColor: Colors.white,
    );
  }

  OutlineInputBorder _buildOutlinedBorder(Color? borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      borderSide: BorderSide(
        color: borderColor ?? ColorManager.grey2,
      ),
    );
  }
}
