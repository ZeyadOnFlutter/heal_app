import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class StepHeader extends StatelessWidget {
  final String step;
  final String title;
  final Color color;
  const StepHeader({super.key, required this.step, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              step,
              style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class AnalysisImagePicker extends StatelessWidget {
  final File? image;
  final Color color;
  final String samplePath;
  final void Function(ImageSource) onPick;
  final VoidCallback onRemove;

  const AnalysisImagePicker({
    super.key,
    required this.image,
    required this.color,
    required this.samplePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sample reference image with label overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Image.asset(
                samplePath,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150.h,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Icon(Icons.image_rounded, size: 40.sp, color: Colors.grey.shade400),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    'Sample Reference',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // Upload area
        GestureDetector(
          onTap: () => onPick(ImageSource.gallery),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 170.h,
            decoration: BoxDecoration(
              color: image != null ? Colors.black : color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: image != null ? color : color.withOpacity(0.35),
                width: 1.8,
              ),
              boxShadow: image != null
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: image != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.file(image!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14.r)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Icon(Icons.close_rounded, color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded, size: 30.sp, color: color),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Upload Your Image',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to browse gallery',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: color,
                onTap: () => onPick(ImageSource.camera),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: color,
                onTap: () => onPick(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
