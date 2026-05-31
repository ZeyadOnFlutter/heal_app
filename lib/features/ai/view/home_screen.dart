import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/service/service_locator.dart';
import '../../auth/presentation/cubit/auth_hydrated_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../widgets/category_card.dart';
import 'diabetes_analysis_screen.dart';
import 'skin_cancer_analysis_screen.dart';
import 'mode_selection_modal.dart';
import '../../clinical_guidance/view/guidance_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthCubit, String>(
      (cubit) => cubit.state is Authenticated
          ? (cubit.state as Authenticated).user.name.split(' ').first
          : 'there',
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // ── Header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName 👋',
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  child: Icon(Icons.person_rounded, color: Colors.blue, size: 24.sp),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ── Hero Banner ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '✨ AI Powered',
                            style: TextStyle(fontSize: 11.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Smart Health\nAnalysis',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Detect conditions early\nwith AI precision',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: 80.sp,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // ── Detection Categories ────────────────────────────────
            _SectionHeader(
              title: 'Detection Categories',
              subtitle: 'Select a condition to analyze',
            ),
            SizedBox(height: 14.h),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.05,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              children: [
                GestureDetector(
                  onTap: () async {
                    final mode = await showModeSelectionModal(
                      context,
                      disease: 'Diabetes',
                      color: Colors.blueAccent,
                    );
                    if (mode != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiabetesAnalysisScreen(predictionMode: mode),
                        ),
                      );
                    }
                  },
                  child: const CategoryCard(
                    icon: '🔬',
                    name: 'Diabetes',
                    color: Colors.blueAccent,
                    subtitle: 'Tongue · Survey · Symptoms',
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final mode = await showModeSelectionModal(
                      context,
                      disease: 'Skin Cancer',
                      color: Color(0xFF6A1B9A),
                    );
                    if (mode != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkinCancerAnalysisScreen(predictionMode: mode),
                        ),
                      );
                    }
                  },
                  child: const CategoryCard(
                    icon: '🔆',
                    name: 'Skin Cancer',
                    color: Color(0xFF6A1B9A),
                    subtitle: 'Skin · Survey · Symptoms',
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // ── Clinical Guidance ───────────────────────────────────
            _SectionHeader(title: 'Clinical Guidance', subtitle: 'Learn about conditions'),
            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: _GuidanceCard(
                    label: 'Diabetes',
                    icon: '🔬',
                    color: const Color(0xFF1E88E5),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuidanceDetailScreen(type: 'diabetes')),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _GuidanceCard(
                    label: 'Skin Cancer',
                    icon: '🔆',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GuidanceDetailScreen(type: 'skin_cancer'),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _GuidanceCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: color),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: color),
          ],
        ),
      ),
    );
  }
}
