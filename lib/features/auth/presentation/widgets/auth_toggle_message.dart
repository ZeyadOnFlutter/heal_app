import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/font_manager.dart';
import '../../../../core/resources/styles_manager.dart';

class AuthToggleMessage extends StatelessWidget {
  const AuthToggleMessage({super.key, this.label1, this.label2, this.onTap});
  final VoidCallback? onTap;
  final String? label1;
  final String? label2;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          text: label1 ?? '',
          style: getRegularStyle(
            color: ColorManager.grey,
            fontSize: FontSize.s12,
          ),
          children: [
            TextSpan(
              text: label2 ?? '',
              style: getMediumStyle(
                color: ColorManager.blue,
                fontSize: FontSize.s12,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
