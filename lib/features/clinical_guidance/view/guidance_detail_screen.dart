import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/guidance_data.dart';

class GuidanceDetailScreen extends StatelessWidget {
  final String type;

  const GuidanceDetailScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final data = switch (type) {
      'diabetes'   => GuidanceData.diabetesGuidance,
      _            => GuidanceData.skinCancerGuidance,
    };

    final color = switch (type) {
      'diabetes'   => const Color(0xFF1E88E5),
      _            => const Color(0xFF6A1B9A),
    };

    final List<Color> gradientColors = switch (type) {
      'diabetes' => [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
      _          => [const Color(0xFF8E24AA), const Color(0xFF6A1B9A)],
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            backgroundColor: color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['icon']!, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Text(
                          data['title']!,
                          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'WHO Clinical Guidance',
                          style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Overview ──────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: color, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          data['overview']!,
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                _GuidanceSection(
                  title: 'Warning Signs',
                  icon: Icons.warning_amber_rounded,
                  color: color,
                  content: data['symptoms']!,
                ),

                SizedBox(height: 14.h),

                _GuidanceSection(
                  title: 'Diet & Nutrition',
                  icon: Icons.restaurant_rounded,
                  color: color,
                  content: data['diet']!,
                ),

                SizedBox(height: 14.h),

                _GuidanceSection(
                  title: 'Self-Care & Lifestyle',
                  icon: Icons.favorite_rounded,
                  color: color,
                  content: data['lifestyle']!,
                ),

                SizedBox(height: 14.h),

                // ── Disclaimer ────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 18.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'This guidance is for educational purposes only. Always consult a qualified healthcare professional for diagnosis and treatment.',
                          style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _GuidanceSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            content,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.7),
          ),
        ],
      ),
    );
  }
}
