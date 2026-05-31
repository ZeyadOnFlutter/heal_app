import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({required this.onTap, required this.buttonText, super.key});

  final void Function() onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(color: const Color.fromRGBO(174, 174, 178, 1), width: 1.w),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 18.h)),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
