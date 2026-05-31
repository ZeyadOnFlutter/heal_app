import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';
import '../resources/values_manager.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    this.maxLines,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.cursorColor,
    this.onTap,
    this.textInputType,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.textCapitalization,
    this.textInputFormatter,
    this.isObscured = false,
    super.key,
  });
  final int? maxLines;
  final String? Function(String?)? validator;
  final String? prefixIcon;
  final String? hintText;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final Color? cursorColor;
  final Color? borderColor;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;
  final TextInputFormatter? textInputFormatter;
  final bool isObscured;
  final Widget? suffixIcon;
  final void Function()? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool hidden;

  @override
  void initState() {
    super.initState();
    hidden = widget.isObscured;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines ?? 1,
      controller: widget.controller,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: getMediumStyle(color: ColorManager.black, fontSize: FontSize.s14),
      obscureText: hidden,
      keyboardType: widget.textInputType,
      obscuringCharacter: '*',
      cursorColor: widget.cursorColor ?? ColorManager.blue,
      onTap: widget.onTap,
      validator: widget.validator,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      onEditingComplete: () {
        widget.focusNode?.unfocus();
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      textInputAction: widget.nextFocus == null ? TextInputAction.done : TextInputAction.next,
      inputFormatters: widget.textInputFormatter != null ? [widget.textInputFormatter!] : const [],
      //onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.s14, vertical: Insets.s18),
        hintText: widget.hintText ?? '',
        errorMaxLines: 2,
        prefixIcon: widget.prefixIcon != null
            ? SvgPicture.asset(widget.prefixIcon!, fit: BoxFit.scaleDown)
            : null,
        suffixIcon: widget.isObscured
            ? IconButton(
                onPressed: () => setState(() => hidden = !hidden),
                iconSize: Sizes.s24.sp,
                splashRadius: Sizes.s1,
                isSelected: !hidden,
                color: ColorManager.black,
                selectedIcon: const Icon(Icons.visibility),
                icon: SvgPicture.asset(SvgAssets.visibilityOff),
              )
            : widget.suffixIcon,
        hintStyle: getMediumStyle(color: ColorManager.grey, fontSize: FontSize.s14),
        enabledBorder: _buildOutlinedBorder(widget.borderColor),
        focusedBorder: _buildOutlinedBorder(ColorManager.blue),
        border: _buildOutlinedBorder(widget.borderColor),
        errorStyle: getLightStyle(color: ColorManager.red),
      ),
    );
  }

  OutlineInputBorder _buildOutlinedBorder(Color? borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      borderSide: BorderSide(color: borderColor ?? ColorManager.grey2),
    );
  }
}
