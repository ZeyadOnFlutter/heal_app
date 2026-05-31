import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../chat/rating_widget.dart';
import '../../../core/widgets/local_or_network_image.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  final String disease;
  final Color color;
  final String icon;

  const AnalysisHistoryScreen({
    super.key,
    required this.disease,
    required this.color,
    required this.icon,
  });

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {

  Stream<List<CombinedAnalysisResult>> _historyStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];
      final raw = (doc.data()?['combinedResults'] as List<dynamic>?) ?? [];
      return raw
          .map((e) => CombinedAnalysisResult.fromJson(Map<String, dynamic>.from(e)))
          .where((r) => r.disease.toLowerCase() == widget.disease.toLowerCase())
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130.h,
            pinned: true,
            backgroundColor: widget.color,
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
                    colors: [widget.color.withOpacity(0.85), widget.color],
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
                        Text(widget.icon, style: TextStyle(fontSize: 28.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          '${widget.disease} History',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Your past analysis results',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: StreamBuilder<List<CombinedAnalysisResult>>(
              stream: _historyStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: widget.color));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _EmptyState(color: widget.color, icon: widget.icon);
                }
                return ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (_, i) => _HistoryCard(result: items[i], color: widget.color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final CombinedAnalysisResult result;
  final Color color;

  const _HistoryCard({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final score = result.finalScore;
    final isHigh = score >= 50;
    final riskColor = isHigh ? Colors.red : Colors.green;
    final riskLabel = isHigh ? 'High Risk' : 'Low Risk';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _HistoryDetailScreen(result: result, color: color)),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: date + badges ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 13.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Text(
                      DateFormat('MMM d, yyyy  HH:mm').format(result.timestamp),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (result.predictionMode == 'fast') ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 11.sp, color: Colors.grey.shade600),
                            SizedBox(width: 2.w),
                            Text(
                              'Fast',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        riskLabel,
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: riskColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Score + progress ──
            Row(
              children: [
                // Big score circle
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withOpacity(0.08),
                    border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${score.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: riskColor),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniBar(label: 'Image', value: result.imgScore, color: color),
                      SizedBox(height: 5.h),
                      _MiniBar(label: 'Survey', value: result.surveyScore, color: color),
                      SizedBox(height: 5.h),
                      _MiniBar(label: 'Symptoms', value: result.nlpScore, color: color),
                    ],
                  ),
                ),
              ],
            ),

            // ── Image thumbnail if available ──
            if (result.imageRecord['imageUrl'] != null &&
                (result.imageRecord['imageUrl'] as String).isNotEmpty) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LocalOrNetworkImage(
                  imageUrl: result.imageRecord['imageUrl'] as String,
                  height: 80.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Container(color: Colors.grey.shade200),
                ),
              ),
            ],

            // ── Text description snippet ──
            if (result.textDescription.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      result.textDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('View details', style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
                SizedBox(width: 3.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 11.sp, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52.w,
          child: Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5.h,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Text('${value.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color color;
  final String icon;
  const _EmptyState({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Text(icon, style: TextStyle(fontSize: 48.sp)),
          ),
          SizedBox(height: 20.h),
          Text('No history yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(
            'Your analysis results will appear here',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Detail Screen ─────────────────────────────────────────────────────────────

class _HistoryDetailScreen extends StatelessWidget {
  final CombinedAnalysisResult result;
  final Color color;

  const _HistoryDetailScreen({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final score = result.finalScore;
    final isHigh = score >= 50;
    final riskColor = isHigh ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          '${result.disease} Detail',
          style: TextStyle(fontSize: 17.sp, color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // ── Score card ──
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: riskColor.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.bold, color: riskColor, height: 1),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isHigh ? 'High Risk' : 'Low Risk',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: riskColor),
                  ),
                ),
                SizedBox(height: 14.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8.h,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  DateFormat('MMMM d, yyyy  HH:mm').format(result.timestamp),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ── Score breakdown ──
          _DetailSection(
            title: 'Score Breakdown',
            icon: Icons.bar_chart_rounded,
            color: color,
            child: Column(
              children: [
                _ScoreDetailRow(label: 'Image Analysis (60%)', score: result.imgScore, color: color),
                SizedBox(height: 8.h),
                _ScoreDetailRow(label: 'Survey (30%)', score: result.surveyScore, color: color),
                SizedBox(height: 8.h),
                _ScoreDetailRow(label: 'Symptom Text (10%)', score: result.nlpScore, color: color),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Image result ──
          _DetailSection(
            title: 'Image Analysis',
            icon: Icons.image_rounded,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.imageRecord['imageUrl'] != null &&
                    (result.imageRecord['imageUrl'] as String).isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LocalOrNetworkImage(
                      imageUrl: result.imageRecord['imageUrl'] as String,
                      height: 160.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: Container(color: Colors.grey.shade200),
                    ),
                  ),
                SizedBox(height: 10.h),
                ..._buildKeyValues(result.imageRecord, exclude: {'imageUrl', 'timestamp'}),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Survey result ──
          _DetailSection(
            title: 'Survey Result',
            icon: Icons.assignment_rounded,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildKeyValues(result.surveyRecord, exclude: {'surveyData', 'timestamp'}),
                if ((result.surveyRecord['surveyData'] as Map?)?.isNotEmpty == true) ...[
                  SizedBox(height: 10.h),
                  Text('Survey Answers', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  ..._buildKeyValues(
                    Map<String, dynamic>.from(result.surveyRecord['surveyData'] as Map),
                    exclude: {},
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Symptom text ──
          if (result.textDescription.isNotEmpty)
            _DetailSection(
              title: 'Symptom Description',
              icon: Icons.chat_bubble_outline_rounded,
              color: color,
              child: Text(
                result.textDescription,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.6),
              ),
            ),

          SizedBox(height: 14.h),

          // ── NLP result ──
          _DetailSection(
            title: 'Text Analysis (NLP)',
            icon: Icons.psychology_rounded,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KVRow(k: 'Match %', v: '${(result.nlpRecord['percentage'] ?? 0.0).toStringAsFixed(1)}%'),
                if ((result.nlpRecord['matched_symptoms'] as List?)?.isNotEmpty == true) ...[
                  SizedBox(height: 8.h),
                  Text('Matched Symptoms', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: (result.nlpRecord['matched_symptoms'] as List)
                        .map((s) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Text(s.toString(), style: TextStyle(fontSize: 11.sp, color: color)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // ── Doctor Feedback ──
          if (result.doctorFeedback.isNotEmpty)
            _DetailSection(
              title: 'Doctor Feedback',
              icon: Icons.medical_services_rounded,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.doctorFeedback,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.6),
                  ),
                  SizedBox(height: 12.h),
                  _DoctorRatingRow(doctorId: result.doctorId),
                ],
              ),
            ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  List<Widget> _buildKeyValues(Map<String, dynamic> map, {required Set<String> exclude}) {
    return map.entries
        .where((e) => !exclude.contains(e.key) && e.value != null)
        .map((e) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: _KVRow(
                k: e.key.replaceAll('_', ' '),
                v: e.value.toString(),
              ),
            ))
        .toList();
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DetailSection({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(icon, color: color, size: 15.sp),
              ),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _ScoreDetailRow extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  const _ScoreDetailRow({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700))),
        SizedBox(width: 8.w),
        SizedBox(
          width: 80.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6.h,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text('${score.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _KVRow extends StatelessWidget {
  final String k;
  final String v;
  const _KVRow({required this.k, required this.v});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(k, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(v, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── Doctor Rating Row ────────────────────────────────────────────────────────────

class _DoctorRatingRow extends StatelessWidget {
  final String doctorId;
  const _DoctorRatingRow({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    if (doctorId.isNotEmpty) {
      return _RatingRow(doctorId: doctorId);
    }
    // Fallback for old results: fetch all doctors and show each one's rating
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _RatingRow(doctorId: '');
        }
        // Use the document ID (which is the UID) directly
        final id = snap.data!.docs.first.id;
        return _RatingRow(doctorId: id);
      },
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String doctorId;
  const _RatingRow({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    if (doctorId.isEmpty) {
      return _ratingContainer(
        stars: List.generate(5, (i) => Icon(Icons.star_border_rounded, color: const Color(0xFFFFD700), size: 14.sp)),
        label: 'No ratings yet',
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .doc(doctorId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _ratingContainer(
            stars: [SizedBox(width: 14.w, height: 14.w, child: const CircularProgressIndicator(strokeWidth: 2))],
            label: '',
          );
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return _ratingContainer(
            stars: List.generate(5, (i) => Icon(Icons.star_border_rounded, color: const Color(0xFFFFD700), size: 14.sp)),
            label: 'No ratings yet',
          );
        }
        final avg = docs
            .map((d) => (d['rating'] as num).toDouble())
            .reduce((a, b) => a + b) / docs.length;
        return _ratingContainer(
          stars: List.generate(5, (i) => Icon(
            i < avg.round() ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFFFD700),
            size: 14.sp,
          )),
          label: '${avg.toStringAsFixed(1)} (${docs.length})',
        );
      },
    );
  }

  Widget _ratingContainer({required List<Widget> stars, required String label}) {
    return Builder(builder: (context) => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_rounded, size: 13.sp, color: Colors.grey),
          SizedBox(width: 6.w),
          Text('Doctor rating: ', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          ...stars,
          if (label.isNotEmpty) ...[
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
          ],
        ],
      ),
    ));
  }
}
