import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
        subtitle: Text(date, style: TextStyle(fontSize: 13.sp)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }
}
