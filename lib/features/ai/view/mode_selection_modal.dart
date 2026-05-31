import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom-sheet modal shown when the user taps Skin Cancer or Diabetes.
/// Returns 'fast' or 'precise' via Navigator.pop when Continue is tapped.
Future<String?> showModeSelectionModal(
  BuildContext context, {
  required String disease,
  required Color color,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModeSelectionSheet(disease: disease, color: color),
  );
}

class _ModeSelectionSheet extends StatefulWidget {
  final String disease;
  final Color color;

  const _ModeSelectionSheet({required this.disease, required this.color});

  @override
  State<_ModeSelectionSheet> createState() => _ModeSelectionSheetState();
}

class _ModeSelectionSheetState extends State<_ModeSelectionSheet> {
  String _selected = 'precise';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            'Choose Analysis Mode',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            'How would you like to analyze ${widget.disease}?',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          SizedBox(height: 20.h),

          // Cards row
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  emoji: '⚡',
                  title: 'Fast',
                  time: '~1–2 min',
                  description:
                      'Upload a single image for a quick preliminary risk score. Best when you need a rapid result.',
                  selected: _selected == 'fast',
                  color: widget.color,
                  onTap: () => setState(() => _selected = 'fast'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ModeCard(
                  emoji: '🎯',
                  title: 'Precise',
                  time: '~5–8 min',
                  description:
                      'Complete a full survey, describe your symptoms, and upload an image for a detailed report with AI heatmaps.',
                  selected: _selected == 'precise',
                  color: widget.color,
                  onTap: () => setState(() => _selected = 'precise'),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String time;
  final String description;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.time,
    required this.description,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 6.w),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: color, size: 16.sp),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.black87,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.12) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: selected ? color : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
