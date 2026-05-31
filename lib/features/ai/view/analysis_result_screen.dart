import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../viewmodel/prediction_state.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String disease;
  final Color color;
  final String icon;
  final CombinedAnalysisSuccess result;

  const AnalysisResultScreen({
    super.key,
    required this.disease,
    required this.color,
    required this.icon,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final score = result.finalScore;
    final isHighRisk = score >= 30;
    final riskColor = isHighRisk ? Colors.red : Colors.green;
    final riskLabel = isHighRisk ? 'High Risk' : 'Low Risk';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.h,
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
                    colors: [color.withOpacity(0.9), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(icon, style: TextStyle(fontSize: 28.sp)),
                        SizedBox(height: 4.h),
                        Text('$disease Analysis Result',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(24.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Fast Mode Banner ───────────────────────────────
                if (result.predictionMode == 'fast') ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.orange.shade700, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Fast Mode Result — For a more accurate analysis, try Precise Mode.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Main Score Card ────────────────────────────────
                Container(
                  padding: EdgeInsets.all(28.w),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: riskColor.withOpacity(0.25), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isHighRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
                          color: riskColor,
                          size: 42.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 52.sp,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 10.h,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Score Breakdown ────────────────────────────────
                Text('Score Breakdown',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),

                _ScoreRow(label: 'Image Analysis', score: result.imgScore, weight: '60%', color: color),
                SizedBox(height: 8.h),
                _ScoreRow(label: 'Survey', score: result.surveyScore, weight: '25%', color: color),
                SizedBox(height: 8.h),
                _ScoreRow(label: 'Symptom Text', score: result.nlpScore, weight: '15%', color: color),

                SizedBox(height: 28.h),

                // ── Disclaimer ─────────────────────────────────────
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
                          'This is an AI-based screening tool. Please consult a healthcare professional for a proper diagnosis.',
                          style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == '/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text('Done',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;
  final String weight;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.score,
    required this.weight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    Text(
                      '${score.toStringAsFixed(1)}%  ·  $weight',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6.h,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
