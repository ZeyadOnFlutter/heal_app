import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialCircleButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const SocialCircleButton({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    this.size = 60,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}
