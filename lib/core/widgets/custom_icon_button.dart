import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.iconData,
    this.iconColor,
    this.size,
    this.onPressed,
  });
  final IconData? iconData;
  final Color? iconColor;
  final double? size;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        iconData,
        color: iconColor,
        size: size,
      ),
      onPressed: onPressed,
    );
  }
}
