import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../auth/data/data_source/firebase_data_source/firebase_auth_data_source.dart';
import '../../auth/data/models/user_model.dart';
import '../../../core/service/service_locator.dart';
import '../../../core/widgets/local_or_network_image.dart';
import 'analysis_history_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firebaseDataSource = getIt<FirebaseAuthDataSource>();
  final _auth = getIt<FirebaseAuth>();
  late Future<UserModel?> _future;

  static const _tabs = [
    _TabMeta('Diabetes',    '🔬', Colors.blueAccent,        Color(0xFF1565C0)),
    _TabMeta('Skin Cancer', '🔆', Color(0xFF6A1B9A),        Color(0xFF4A148C)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _future = _firebaseDataSource.getUserData(_auth.currentUser!.uid);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
        _future = _firebaseDataSource.getUserData(_auth.currentUser!.uid);
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Analyses', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2.h),
                    Text('Combined results history', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                  ],
                ),
                GestureDetector(
                  onTap: _reload,
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.refresh_rounded, size: 20.sp, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Tab Bar ──────────────────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.all(4.w),
              tabs: _tabs.map((t) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.icon, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Text(t.label.split(' ').first, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              )).toList(),
            ),
          ),

          SizedBox(height: 16.h),

          // ── Content ──────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<UserModel?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = snapshot.data;
                if (user == null) {
                  return Center(child: Text('No data available', style: TextStyle(fontSize: 14.sp)));
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _DiseaseTab(
                      combinedResults: user.combinedResults
                          .where((r) => r.disease.toLowerCase() == 'diabetes')
                          .toList()
                        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
                      meta: _tabs[0],
                    ),
                    _DiseaseTab(
                      combinedResults: user.combinedResults
                          .where((r) => r.disease.toLowerCase() == 'skin cancer')
                          .toList()
                        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
                      meta: _tabs[1],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab meta ──────────────────────────────────────────────────────────────────

class _TabMeta {
  final String label;
  final String icon;
  final Color color;
  final Color darkColor;
  const _TabMeta(this.label, this.icon, this.color, this.darkColor);
}

// ── Disease Tab ───────────────────────────────────────────────────────────────

class _DiseaseTab extends StatelessWidget {
  final List<CombinedAnalysisResult> combinedResults;
  final _TabMeta meta;

  const _DiseaseTab({required this.combinedResults, required this.meta});

  @override
  Widget build(BuildContext context) {
    if (combinedResults.isEmpty) {
      return _EmptyTab(meta: meta);
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      itemCount: combinedResults.length,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (_, i) => _CombinedCard(result: combinedResults[i], meta: meta),
    );
  }
}

// ── Empty Tab ─────────────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final _TabMeta meta;
  const _EmptyTab({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(color: meta.color.withOpacity(0.08), shape: BoxShape.circle),
            child: Text(meta.icon, style: TextStyle(fontSize: 44.sp)),
          ),
          SizedBox(height: 18.h),
          Text('No ${meta.label} analyses yet', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 6.h),
          Text('Complete an analysis to see results here', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Combined Card ─────────────────────────────────────────────────────────────

class _CombinedCard extends StatelessWidget {
  final CombinedAnalysisResult result;
  final _TabMeta meta;

  const _CombinedCard({required this.result, required this.meta});

  @override
  Widget build(BuildContext context) {
    final score = result.finalScore;
    final isHigh = score >= 50;
    final riskColor = isHigh ? Colors.red : Colors.green;
    final imageUrl = result.imageRecord['imageUrl'] as String? ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _HistoryDetailScreen(result: result, meta: meta)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image banner ──
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                child: LocalOrNetworkImage(
                  imageUrl: imageUrl,
                  height: 130.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Container(color: Colors.grey.shade200),
                ),
              )
            else
              Container(
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                  gradient: LinearGradient(
                    colors: [meta.darkColor, meta.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(child: Text(meta.icon, style: TextStyle(fontSize: 36.sp))),
              ),

            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date + risk badge ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.calendar_today_rounded, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(DateFormat('MMM d, yyyy  HH:mm').format(result.timestamp),
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      ]),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          isHigh ? 'High Risk' : 'Low Risk',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: riskColor),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // ── Score + bars ──
                  Row(
                    children: [
                      Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: riskColor.withOpacity(0.08),
                          border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
                        ),
                        child: Center(
                          child: Text('${score.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: riskColor)),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          children: [
                            _MiniBar(label: 'Image',    value: result.imgScore,    color: meta.color),
                            SizedBox(height: 5.h),
                            _MiniBar(label: 'Survey',   value: result.surveyScore, color: meta.color),
                            SizedBox(height: 5.h),
                            _MiniBar(label: 'Symptoms', value: result.nlpScore,    color: meta.color),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Symptom snippet ──
                  if (result.textDescription.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 13.sp, color: Colors.grey),
                          SizedBox(width: 6.w),
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
                    ),
                  ],

                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (result.doctorFeedback.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.teal.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.medical_services_rounded, size: 11.sp, color: Colors.teal),
                            SizedBox(width: 4.w),
                            Text('Doctor feedback', style: TextStyle(fontSize: 10.sp, color: Colors.teal, fontWeight: FontWeight.w600)),
                          ]),
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          Text('View details', style: TextStyle(fontSize: 12.sp, color: meta.color, fontWeight: FontWeight.w600)),
                          SizedBox(width: 3.w),
                          Icon(Icons.arrow_forward_ios_rounded, size: 11.sp, color: meta.color),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
        SizedBox(width: 52.w, child: Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey))),
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

// ── Detail Screen ─────────────────────────────────────────────────────────────

class _HistoryDetailScreen extends StatelessWidget {
  final CombinedAnalysisResult result;
  final _TabMeta meta;

  const _HistoryDetailScreen({required this.result, required this.meta});

  @override
  Widget build(BuildContext context) {
    final score = result.finalScore;
    final isHigh = score >= 50;
    final riskColor = isHigh ? Colors.red : Colors.green;
    final imageUrl = result.imageRecord['imageUrl'] as String? ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 220.h : 130.h,
            pinned: true,
            backgroundColor: meta.color,
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
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        LocalOrNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: Container(color: Colors.black12),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, meta.color.withOpacity(0.85)],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16.h,
                          left: 20.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meta.icon, style: TextStyle(fontSize: 26.sp)),
                              Text('${meta.label} Analysis Detail',
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [meta.darkColor, meta.color]),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meta.icon, style: TextStyle(fontSize: 26.sp)),
                              Text('${meta.label} Analysis Detail',
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
                // ── Score card ──
                Container(
                  padding: EdgeInsets.all(22.w),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: riskColor.withOpacity(0.2), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text('${score.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 46.sp, fontWeight: FontWeight.bold, color: riskColor, height: 1)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(isHigh ? 'High Risk' : 'Low Risk',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: riskColor)),
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
                      Text(DateFormat('MMMM d, yyyy  HH:mm').format(result.timestamp),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Score breakdown ──
                _Section(
                  title: 'Score Breakdown',
                  icon: Icons.bar_chart_rounded,
                  color: meta.color,
                  child: Column(children: [
                    _ScoreRow(label: 'Image Analysis (60%)', score: result.imgScore,    color: meta.color),
                    SizedBox(height: 8.h),
                    _ScoreRow(label: 'Survey (30%)',         score: result.surveyScore, color: meta.color),
                    SizedBox(height: 8.h),
                    _ScoreRow(label: 'Symptom Text (10%)',   score: result.nlpScore,    color: meta.color),
                  ]),
                ),

                SizedBox(height: 14.h),

                // ── Image result ──
                _Section(
                  title: 'Image Analysis',
                  icon: Icons.image_rounded,
                  color: meta.color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._kvRows(result.imageRecord, exclude: {'imageUrl', 'timestamp'}),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ── Survey result ──
                _Section(
                  title: 'Survey Result',
                  icon: Icons.assignment_rounded,
                  color: meta.color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._kvRows(result.surveyRecord, exclude: {'surveyData', 'timestamp'}),
                      if ((result.surveyRecord['surveyData'] as Map?)?.isNotEmpty == true) ...[
                        SizedBox(height: 10.h),
                        Text('Survey Answers',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: meta.color)),
                        SizedBox(height: 6.h),
                        ..._kvRows(
                          Map<String, dynamic>.from(result.surveyRecord['surveyData'] as Map),
                          exclude: {},
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ── Symptom text ──
                if (result.textDescription.isNotEmpty) ...[
                  _Section(
                    title: 'Symptom Description',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: meta.color,
                    child: Text(result.textDescription,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.6)),
                  ),
                  SizedBox(height: 14.h),
                ],

                // ── NLP ──
                _Section(
                  title: 'Text Analysis (NLP)',
                  icon: Icons.psychology_rounded,
                  color: meta.color,
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
                                      color: meta.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(color: meta.color.withOpacity(0.3)),
                                    ),
                                    child: Text(s.toString(),
                                        style: TextStyle(fontSize: 11.sp, color: meta.color)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Doctor Feedback ──
                if (result.doctorFeedback.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _Section(
                    title: 'Doctor Feedback',
                    icon: Icons.medical_services_rounded,
                    color: Colors.teal,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.teal.withOpacity(0.2)),
                      ),
                      child: Text(
                        result.doctorFeedback,
                        style: TextStyle(fontSize: 13.sp, color: Colors.teal.shade700, height: 1.6),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 30.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _kvRows(Map<String, dynamic> map, {required Set<String> exclude}) =>
      map.entries
          .where((e) => !exclude.contains(e.key) && e.value != null)
          .map((e) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: _KVRow(k: e.key.replaceAll('_', ' '), v: e.value.toString()),
              ))
          .toList();
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _Section({required this.title, required this.icon, required this.color, required this.child});

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
          Row(children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
              child: Icon(icon, color: color, size: 15.sp),
            ),
            SizedBox(width: 8.w),
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  const _ScoreRow({required this.label, required this.score, required this.color});

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
          Expanded(child: Text(v, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
