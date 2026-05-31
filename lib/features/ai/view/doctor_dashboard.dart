import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/service/service_locator.dart';
import '../../../core/widgets/local_or_network_image.dart';
import '../../auth/data/data_source/firebase_data_source/firebase_auth_data_source.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/presentation/cubit/auth_hydrated_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../auth/presentation/view/login.dart';
import '../../chat/chat_list_screen.dart';
import '../../chat/rating_widget.dart';
import '../../../core/service/backend_service.dart';
import 'training_data_section.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [_PatientsTab(), const ChatListScreen()];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.people_alt_rounded, label: 'Patients', selected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0)),
            _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', selected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 18.w : 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00E5FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF0A0E1A) : Colors.grey, size: 22.sp),
            if (selected) ...[
              SizedBox(width: 6.w),
              Text(label,
                  style: TextStyle(
                      color: const Color(0xFF0A0E1A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Patients Tab ──────────────────────────────────────────────────────────────

class _PatientsTab extends StatefulWidget {
  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  final _dataSource = getIt<FirebaseAuthDataSource>();
  late Future<List<UserModel>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _loadPatients();
  }

  Future<List<UserModel>> _loadPatients() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();
    return snap.docs
        .map((d) => UserModel.fromJson({...d.data(), 'id': d.id}))
        .where((u) =>
            u.consentDoctorAccess == true &&
            u.combinedResults.any((r) => r.doctorFeedback.isEmpty))
        .toList();
  }

  void _reload() {
    final f = _loadPatients();
    setState(() { _future = f; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                }
                final patients = (snapshot.data ?? []).where((p) {
                  if (_search.isEmpty) return true;
                  return p.name.toLowerCase().contains(_search.toLowerCase()) ||
                      p.email.toLowerCase().contains(_search.toLowerCase());
                }).toList();

                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded, color: Colors.white24, size: 52.sp),
                        SizedBox(height: 12.h),
                        Text('No patients found', style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _PatientTile(
                    patient: patients[i],
                    dataSource: _dataSource,
                    onFeedbackSaved: _reload,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF111827),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFF00E5FF).withOpacity(0.3)),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
            ),
            child: Icon(Icons.medical_services_rounded, color: const Color(0xFF00E5FF), size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Text('Patients',
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.white54, size: 22.sp),
          onPressed: _reload,
        ),
        IconButton(
          icon: Icon(Icons.logout_rounded, color: Colors.white54, size: 22.sp),
          onPressed: () async {
            await context.read<AuthCubit>().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Login()),
                (r) => false,
              );
            }
          },
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF111827),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF1E2D45)),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search patients...',
            hintStyle: TextStyle(color: Colors.white30, fontSize: 13.sp),
            prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF00E5FF), size: 20.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
    );
  }
}

// ── Patient Tile ──────────────────────────────────────────────────────────────

class _PatientTile extends StatelessWidget {
  final UserModel patient;
  final FirebaseAuthDataSource dataSource;
  final VoidCallback onFeedbackSaved;

  const _PatientTile({
    required this.patient,
    required this.dataSource,
    required this.onFeedbackSaved,
  });

  @override
  Widget build(BuildContext context) {
    final resultCount = patient.combinedResults.where((r) => r.doctorFeedback.isEmpty).length;
    final pendingFeedback = patient.combinedResults.where((r) => r.doctorFeedback.isEmpty).length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PatientResultsScreen(
            patient: patient,
            dataSource: dataSource,
            onFeedbackSaved: onFeedbackSaved,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: pendingFeedback > 0
                ? const Color(0xFF00E5FF).withOpacity(0.3)
                : const Color(0xFF1E2D45),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: const Color(0xFF00E5FF), fontWeight: FontWeight.w800, fontSize: 16.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  RatingWidget(userId: patient.id),
                  SizedBox(height: 2.h),
                  Text(patient.email,
                      style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                  ),
                  child: Text('$resultCount results',
                      style: TextStyle(
                          color: const Color(0xFF00E676), fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
                if (pendingFeedback > 0) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                    ),
                    child: Text('$pendingFeedback pending',
                        style: TextStyle(
                            color: const Color(0xFF00E5FF), fontSize: 10.sp, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14.sp),
          ],
        ),
      ),
    );
  }
}

// ── Patient Results Screen ────────────────────────────────────────────────────

class _PatientResultsScreen extends StatefulWidget {
  final UserModel patient;
  final FirebaseAuthDataSource dataSource;
  final VoidCallback onFeedbackSaved;

  const _PatientResultsScreen({
    required this.patient,
    required this.dataSource,
    required this.onFeedbackSaved,
  });

  @override
  State<_PatientResultsScreen> createState() => _PatientResultsScreenState();
}

class _PatientResultsScreenState extends State<_PatientResultsScreen> {
  late List<CombinedAnalysisResult> _results;

  static const _diseaseColors = {
    'diabetes': Colors.blueAccent,
    'skin cancer': Color(0xFF6A1B9A),
  };

  static const _diseaseIcons = {
    'diabetes': '🔬',
    'skin cancer': '🔆',
  };

  @override
  void initState() {
    super.initState();
    _results = widget.patient.combinedResults
        .where((r) => r.doctorFeedback.isEmpty)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Color _colorFor(String disease) =>
      _diseaseColors[disease.toLowerCase()] ?? Colors.blueAccent;

  String _iconFor(String disease) =>
      _diseaseIcons[disease.toLowerCase()] ?? '🏥';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.patient.name,
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            Text('${_results.length} analysis results',
                style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
          ],
        ),
      ),
      body: _results.isEmpty
          ? Center(
              child: Text('No results', style: TextStyle(color: Colors.white38, fontSize: 14.sp)))
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: _results.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) => _ResultCard(
                result: _results[i],
                color: _colorFor(_results[i].disease),
                icon: _iconFor(_results[i].disease),
                patientId: widget.patient.id,
                consentModelTraining: widget.patient.consentModelTraining == true,
                dataSource: widget.dataSource,
                onFeedbackSaved: (feedback) {
                  setState(() => _results.removeAt(i));
                  widget.onFeedbackSaved();
                  if (_results.isEmpty && mounted) Navigator.pop(context);
                },
              ),
            ),
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatefulWidget {
  final CombinedAnalysisResult result;
  final Color color;
  final String icon;
  final String patientId;
  final bool consentModelTraining;
  final FirebaseAuthDataSource dataSource;
  final void Function(String) onFeedbackSaved;

  const _ResultCard({
    required this.result,
    required this.color,
    required this.icon,
    required this.patientId,
    required this.consentModelTraining,
    required this.dataSource,
    required this.onFeedbackSaved,
  });

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _expanded = false;
  bool _editingFeedback = false;
  late TextEditingController _feedbackController;
  bool _saving = false;

  bool get _hasFeedback => widget.result.doctorFeedback.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController(text: widget.result.doctorFeedback);
    // If feedback already exists, don't allow editing
    _editingFeedback = false;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _saveFeedback() async {
    setState(() => _saving = true);
    final doctorId = context.read<AuthCubit>().currentUser?.id ?? '';
    await widget.dataSource.saveDoctorFeedback(
      widget.patientId,
      widget.result.timestamp.toIso8601String(),
      _feedbackController.text.trim(),
      doctorId,
    );
    setState(() {
      _saving = false;
      _editingFeedback = false;
    });
    widget.onFeedbackSaved(_feedbackController.text.trim());

    // Notify backend to push FCM notification to patient.
    BackendService.instance.sendFeedbackNotification(
      patientId: widget.patientId,
      doctorId: doctorId,
      feedback: _feedbackController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feedback saved'),
          backgroundColor: const Color(0xFF1A3D2B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.result.finalScore;
    final isHigh = score >= 50;
    final riskColor = isHigh ? Colors.redAccent : const Color(0xFF00E676);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2235),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: widget.color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          // ── Image (always visible) ──
          if ((widget.result.imageRecord['imageUrl'] as String? ?? '').isNotEmpty) ...[
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullscreenImageScreen(
                    imagePath: widget.result.imageRecord['imageUrl'] as String,
                    disease: widget.result.disease,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LocalOrNetworkImage(
                      imageUrl: widget.result.imageRecord['imageUrl'] as String,
                      height: 160.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: Container(color: Colors.black12),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Icon(Icons.zoom_in_rounded, color: Colors.white, size: 24.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Header ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Text(widget.icon, style: TextStyle(fontSize: 22.sp)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.result.disease,
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('MMM d, yyyy  HH:mm').format(widget.result.timestamp),
                          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  // Risk badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: riskColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(0)}%  ${isHigh ? '⚠️' : '✅'}',
                      style: TextStyle(
                          color: riskColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: Colors.white38,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ──
          if (_expanded) ...[
            Divider(color: const Color(0xFF1E2D45), height: 1),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score bars
                  _DarkScoreRow(label: 'Image (60%)',   value: widget.result.imgScore,    color: widget.color),
                  SizedBox(height: 6.h),
                  _DarkScoreRow(label: 'Survey (30%)',  value: widget.result.surveyScore, color: widget.color),
                  SizedBox(height: 6.h),
                  _DarkScoreRow(label: 'Symptoms (10%)', value: widget.result.nlpScore,   color: widget.color),

                  // Symptom text
                  if (widget.result.textDescription.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _DarkSection(
                      label: 'Patient Description',
                      child: Text(widget.result.textDescription,
                          style: TextStyle(color: Colors.white70, fontSize: 12.sp, height: 1.5)),
                    ),
                  ],

                  // Survey answers
                  if ((widget.result.surveyRecord['surveyData'] as Map?)?.isNotEmpty == true) ...[
                    SizedBox(height: 10.h),
                    _DarkSection(
                      label: 'Survey Answers',
                      child: Column(
                        children: (widget.result.surveyRecord['surveyData'] as Map)
                            .entries
                            .map((e) => Padding(
                                  padding: EdgeInsets.only(bottom: 3.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 130.w,
                                        child: Text(
                                          e.key.toString().replaceAll('_', ' '),
                                          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          e.value.toString(),
                                          style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  SizedBox(height: 14.h),

                  // ── Training Data Label ──
                  TrainingDataSection(
                    result: widget.result,
                    patientId: widget.patientId,
                    consentModelTraining: widget.consentModelTraining,
                  ),

                  SizedBox(height: 14.h),

                  // ── Doctor Feedback ──
                  _DarkSection(
                    label: 'Doctor Feedback',
                    trailing: _hasFeedback
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.check_circle_rounded, size: 11.sp, color: const Color(0xFF00E676)),
                              SizedBox(width: 4.w),
                              Text('Submitted', style: TextStyle(color: const Color(0xFF00E676), fontSize: 10.sp, fontWeight: FontWeight.w600)),
                            ]),
                          )
                        : null,
                    child: _hasFeedback
                        ? Text(
                            widget.result.doctorFeedback,
                            style: TextStyle(color: Colors.white70, fontSize: 13.sp, height: 1.5),
                          )
                        : _editingFeedback || !_hasFeedback
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextField(
                                    controller: _feedbackController,
                                    maxLines: 4,
                                    style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                    decoration: InputDecoration(
                                      hintText: 'Write your medical feedback here...',
                                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12.sp),
                                      filled: true,
                                      fillColor: const Color(0xFF0A0E1A),
                                      contentPadding: EdgeInsets.all(12.w),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(color: Color(0xFF1E2D45)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(color: Color(0xFF1E2D45)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  GestureDetector(
                                    onTap: _saving ? null : _saveFeedback,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                                      ),
                                      child: _saving
                                          ? SizedBox(
                                              width: 14.w,
                                              height: 14.w,
                                              child: const CircularProgressIndicator(
                                                  color: Color(0xFF00E5FF), strokeWidth: 2),
                                            )
                                          : Text('Save Feedback',
                                              style: TextStyle(
                                                  color: const Color(0xFF00E5FF),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Fullscreen Image Screen ──────────────────────────────────────────────────

class _FullscreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String disease;

  const _FullscreenImageScreen({required this.imagePath, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: Text(disease, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: LocalOrNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.contain,
            placeholder: Container(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

// ── Dark shared widgets ───────────────────────────────────────────────────────

class _DarkScoreRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _DarkScoreRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90.w, child: Text(label, style: TextStyle(color: Colors.white38, fontSize: 11.sp))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5.h,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.8)),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text('${value.toStringAsFixed(0)}%', style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
      ],
    );
  }
}

class _DarkSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;
  const _DarkSection({required this.label, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF1E2D45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white54, fontSize: 11.sp, fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
