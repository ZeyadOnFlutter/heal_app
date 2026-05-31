import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingWidget extends StatelessWidget {
  final String userId;
  final Color color;

  const RatingWidget({super.key, required this.userId, this.color = const Color(0xFFFFD700)});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .doc(userId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border_rounded, color: color, size: 13.sp),
              SizedBox(width: 3.w),
              Text('No ratings', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
            ],
          );
        }
        final docs = snap.data!.docs;
        final avg = docs
                .map((d) => (d['rating'] as num).toDouble())
                .reduce((a, b) => a + b) /
            docs.length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (i) => Icon(
              i < avg.round() ? Icons.star_rounded : Icons.star_border_rounded,
              color: color,
              size: 13.sp,
            )),
            SizedBox(width: 4.w),
            Text(
              '${avg.toStringAsFixed(1)} (${docs.length})',
              style: TextStyle(color: Colors.grey, fontSize: 11.sp),
            ),
          ],
        );
      },
    );
  }
}
