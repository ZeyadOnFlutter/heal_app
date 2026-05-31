import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/service/service_locator.dart';
import '../../auth/presentation/cubit/auth_hydrated_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../auth/presentation/view/login.dart';
import '../viewmodel/admin_cubit.dart';
import '../viewmodel/admin_state.dart';
import '../widgets/user_form_dialog.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0E1A);
const _surface = Color(0xFF111827);
const _card = Color(0xFF1A2235);
const _cyan = Color(0xFF00E5FF);
const _purple = Color(0xFF7C3AED);
const _green = Color(0xFF00E676);
const _border = Color(0xFF1E2D45);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadUsers(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView> {
  String _filterRole = 'all';
  String _search = '';
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      floatingActionButton: _selectedIndex == 0 ? _buildFab(context) : null,
      bottomNavigationBar: _buildBottomNav(),
      body: _selectedIndex == 0
          ? BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  _showSnack(context, state.message, isError: true);
                } else if (state is AdminSuccess) {
                  _showSnack(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) return _buildLoading();
                if (state is AdminError) return _buildError(context, state.message);
                if (state is AdminLoaded) return _buildContent(context, state);
                return const SizedBox();
              },
            )
          : const _ModelPerformancePage(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AdminNavItem(
            icon: Icons.people_alt_rounded,
            label: 'Users',
            selected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _AdminNavItem(
            icon: Icons.model_training_rounded,
            label: 'Performance',
            selected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cyan.withOpacity(0.3)),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _cyan.withOpacity(0.4)),
            ),
            child: Icon(Icons.shield_rounded, color: _cyan, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Text(
            'Admin Console',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
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

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: _cyan.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
      ),
      child: FloatingActionButton(
        backgroundColor: _cyan,
        onPressed: () => _showCreateDialog(context),
        child: Icon(Icons.person_add_rounded, color: _bg, size: 24.sp),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: CircularProgressIndicator(color: _cyan, strokeWidth: 2),
          ),
          SizedBox(height: 16.h),
          Text('Loading users...', style: TextStyle(color: Colors.white38, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48.sp),
          SizedBox(height: 12.h),
          Text(message, style: TextStyle(color: Colors.white54, fontSize: 13.sp), textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          _NeonButton(
            label: 'Retry',
            color: _cyan,
            onTap: () => context.read<AdminCubit>().loadUsers(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminLoaded state) {
    final filtered = state.users.where((u) {
      final matchRole = _filterRole == 'all' || u.role == _filterRole;
      final matchSearch = _search.isEmpty ||
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase());
      return matchRole && matchSearch;
    }).toList();

    return Column(
      children: [
        _buildStatsBar(state),
        _buildFilters(),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, color: Colors.white24, size: 48.sp),
                      SizedBox(height: 8.h),
                      Text('No users found', style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) => _UserTile(
                    user: filtered[i],
                    onEdit: () => _showEditDialog(context, filtered[i]),
                    onDelete: () => _confirmDelete(context, filtered[i].id, filtered[i].role),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(AdminLoaded state) {
    final counts = {
      'Total': state.users.length,
      'Patients': state.users.where((u) => u.role == 'patient').length,
      'Doctors': state.users.where((u) => u.role == 'doctor').length,
      'Admins': state.users.where((u) => u.role == 'admin').length,
    };
    final colors = [_cyan, _green, Colors.blueAccent, _purple];

    return Container(
      color: _surface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: counts.entries.toList().asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: idx < 3 ? 8.w : 0),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: colors[idx].withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: colors[idx].withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  Text(
                    '${entry.value}',
                    style: TextStyle(color: colors[idx], fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    entry.key,
                    style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: _surface,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _border),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 13.sp),
                prefixIcon: Icon(Icons.search_rounded, color: _cyan, size: 20.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'patient', 'doctor', 'admin'].map((role) {
                final selected = _filterRole == role;
                final color = _roleColor(role);
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.15) : _card,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: selected ? color : _border),
                    ),
                    child: Text(
                      role == 'all' ? 'All' : '${role[0].toUpperCase()}${role.substring(1)}s',
                      style: TextStyle(
                        color: selected ? color : Colors.white38,
                        fontSize: 12.sp,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) => switch (role) {
        'admin' => _purple,
        'doctor' => Colors.blueAccent,
        'all' => _cyan,
        _ => _green,
      };

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFF3D1A1A) : const Color(0xFF1A3D2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(color: isError ? Colors.redAccent : _green, width: 1),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const UserFormDialog(),
    );
    if (result != null && context.mounted) {
      context.read<AdminCubit>().createUser(result['user'], result['password']);
    }
  }

  void _showEditDialog(BuildContext context, user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if (result != null && context.mounted) {
      context.read<AdminCubit>().updateUser(result['user'], result['oldRole']);
    }
  }

  void _confirmDelete(BuildContext context, String userId, String role) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28.sp),
              ),
              SizedBox(height: 16.h),
              Text('Delete User', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _NeonButton(
                      label: 'Cancel',
                      color: Colors.white24,
                      textColor: Colors.white70,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _NeonButton(
                      label: 'Delete',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AdminCubit>().deleteUser(userId, role);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Model Performance Page ────────────────────────────────────────────────────

class _DiseasePerf {
  final int total;
  final Map<String, int> counts;
  final int agreedCount;
  final int comparableCount;

  const _DiseasePerf({
    required this.total,
    required this.counts,
    required this.agreedCount,
    required this.comparableCount,
  });

  double get accuracy => comparableCount > 0 ? agreedCount / comparableCount * 100 : 0.0;

  /// Maps raw model output strings to the canonical label values so that
  /// records saved before normalization was enforced still compare correctly.
  static String _normalize(String raw, String diseaseKey) {
    final s = raw.toLowerCase().trim();
    if (diseaseKey == 'diabetes') {
      if (s.contains('non') || s == 'non_diabetic') return 'non_diabetic';
      if (s.contains('diab') || s == 'diabetic') return 'diabetic';
      return s;
    }
    if (diseaseKey == 'skin_cancer') {
      final u = raw.toUpperCase().trim();
      if (u == 'MEL' || u == 'BCC' || s == 'positive') return 'positive';
      if (u == 'NV' || s == 'negative') return 'negative';
      return s;
    }
    return s;
  }

  factory _DiseasePerf.fromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    List<String> labels,
    String diseaseKey,
  ) {
    final counts = {for (final l in labels) l: 0};
    int agreed = 0;
    int comparable = 0;
    for (final doc in docs) {
      final data = doc.data();
      final label = (data['label'] as String?) ?? '';
      final rawPrediction = (data['model_prediction'] as String?) ?? '';
      final prediction = _normalize(rawPrediction, diseaseKey);
      if (counts.containsKey(label)) counts[label] = counts[label]! + 1;
      // Exclude 'insufficient' from agreement — no meaningful ground truth.
      if (label.isNotEmpty && label != 'insufficient') {
        comparable++;
        if (label == prediction) agreed++;
      }
    }
    return _DiseasePerf(
      total: docs.length,
      counts: counts,
      agreedCount: agreed,
      comparableCount: comparable,
    );
  }
}

class _LabelDef {
  final String key;
  final String display;
  final IconData icon;
  final Color color;
  const _LabelDef({required this.key, required this.display, required this.icon, required this.color});
}

// ── Full performance page shown on the Performance tab ───────────────────────

class _ModelPerformancePage extends StatefulWidget {
  const _ModelPerformancePage();

  @override
  State<_ModelPerformancePage> createState() => _ModelPerformancePageState();
}

class _ModelPerformancePageState extends State<_ModelPerformancePage> {
  bool _loading = true;
  bool _error = false;
  _DiseasePerf? _diabetes;
  _DiseasePerf? _skinCancer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final db = FirebaseFirestore.instance;
      final results = await Future.wait([
        db.collection('training_data').doc('diabetes').collection('records').get(),
        db.collection('training_data').doc('skin_cancer').collection('records').get(),
      ]);
      setState(() {
        _diabetes = _DiseasePerf.fromDocs(results[0].docs, ['diabetic', 'non_diabetic', 'insufficient'], 'diabetes');
        _skinCancer = _DiseasePerf.fromDocs(results[1].docs, ['positive', 'negative', 'insufficient'], 'skin_cancer');
        _loading = false;
      });
    } catch (_) {
      setState(() { _loading = false; _error = true; });
    }
  }

  Color _agreementColor(double pct) {
    if (pct >= 75) return _green;
    if (pct >= 50) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 40.w, height: 40.w,
                child: const CircularProgressIndicator(color: _cyan, strokeWidth: 2)),
            SizedBox(height: 16.h),
            Text('Loading performance data…', style: TextStyle(color: Colors.white38, fontSize: 13.sp)),
          ],
        ),
      );
    }

    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48.sp),
            SizedBox(height: 12.h),
            Text('Failed to load data', style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
            SizedBox(height: 16.h),
            _NeonButton(label: 'Retry', color: _cyan, onTap: _load),
          ],
        ),
      );
    }

    final total = (_diabetes?.total ?? 0) + (_skinCancer?.total ?? 0);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      children: [
        // ── Page header ──
        Row(
          children: [
            Icon(Icons.model_training_rounded, color: _cyan, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model Performance',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  Text('Based on doctor-reviewed AI predictions',
                      style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                ],
              ),
            ),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: _border),
                ),
                child: Icon(Icons.refresh_rounded, color: Colors.white54, size: 18.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ── Total labeled records ──
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _cyan.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text('$total',
                  style: TextStyle(color: _cyan, fontSize: 28.sp, fontWeight: FontWeight.w800)),
              Text('Total Labeled Records',
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 2.h),
              Text('Records reviewed and labeled by doctors',
                  style: TextStyle(color: Colors.white24, fontSize: 10.sp)),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Diabetes ──
        _DiseasePerfCard(
          title: 'Diabetes',
          emoji: '🔬',
          perf: _diabetes,
          agreementColor: _agreementColor(_diabetes?.accuracy ?? 0),
          labelDefs: const [
            _LabelDef(key: 'diabetic',     display: 'Diabetic',     icon: Icons.check_circle_outline_rounded, color: Colors.redAccent),
            _LabelDef(key: 'non_diabetic', display: 'Non-Diabetic', icon: Icons.cancel_outlined,              color: _green),
            _LabelDef(key: 'insufficient', display: 'Insufficient', icon: Icons.warning_amber_rounded,        color: Colors.orange),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Skin Cancer ──
        _DiseasePerfCard(
          title: 'Skin Cancer',
          emoji: '🔆',
          perf: _skinCancer,
          agreementColor: _agreementColor(_skinCancer?.accuracy ?? 0),
          labelDefs: const [
            _LabelDef(key: 'positive',     display: 'Malignant',    icon: Icons.check_circle_outline_rounded, color: Colors.redAccent),
            _LabelDef(key: 'negative',     display: 'Benign',       icon: Icons.cancel_outlined,              color: _green),
            _LabelDef(key: 'insufficient', display: 'Insufficient', icon: Icons.warning_amber_rounded,        color: Colors.orange),
          ],
        ),
      ],
    );
  }
}

// ── Disease performance card ──────────────────────────────────────────────────

class _DiseasePerfCard extends StatelessWidget {
  final String title;
  final String emoji;
  final _DiseasePerf? perf;
  final Color agreementColor;
  final List<_LabelDef> labelDefs;

  const _DiseasePerfCard({
    required this.title,
    required this.emoji,
    required this.perf,
    required this.agreementColor,
    required this.labelDefs,
  });

  @override
  Widget build(BuildContext context) {
    final p = perf;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 8.w),
                Text(title,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                  ),
                  child: Text('${p?.total ?? 0} records',
                      style: TextStyle(color: _cyan, fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),

          if (p == null || p.total == 0)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, color: Colors.white24, size: 32.sp),
                    SizedBox(height: 8.h),
                    Text('No labeled records yet',
                        style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                  ],
                ),
              ),
            )
          else ...[
            // Section: Doctor's Assessment
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital_rounded, color: Colors.blueAccent, size: 13.sp),
                      SizedBox(width: 5.w),
                      Text("Doctor's Assessment",
                          style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text('How doctors classified each case after reviewing the AI analysis',
                      style: TextStyle(color: Colors.white30, fontSize: 10.sp)),
                  SizedBox(height: 10.h),
                  Row(
                    children: labelDefs.asMap().entries.map((e) {
                      final isLast = e.key == labelDefs.length - 1;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
                          child: _LabelCountChip(def: e.value, count: p.counts[e.value.key] ?? 0),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Divider between sections
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: const Divider(color: _border, height: 1),
            ),

            // Section: AI Agreement
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.model_training_rounded, color: _cyan, size: 13.sp),
                      SizedBox(width: 5.w),
                      Text('AI Prediction Agreement',
                          style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'How often the model\'s initial prediction matched the doctor\'s final diagnosis'
                    '${p.counts['insufficient']! > 0 ? ' (insufficient cases excluded)' : ''}',
                    style: TextStyle(color: Colors.white30, fontSize: 10.sp),
                  ),
                  SizedBox(height: 12.h),
                  if (p.comparableCount == 0)
                    Text('Not enough comparable records',
                        style: TextStyle(color: Colors.white24, fontSize: 11.sp))
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: LinearProgressIndicator(
                              value: p.accuracy / 100,
                              minHeight: 8.h,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(agreementColor),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text('${p.accuracy.toStringAsFixed(1)}%',
                            style: TextStyle(
                                color: agreementColor, fontSize: 15.sp, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${p.agreedCount} of ${p.comparableCount} cases agreed',
                      style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelCountChip extends StatelessWidget {
  final _LabelDef def;
  final int count;
  const _LabelCountChip({required this.def, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: def.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: def.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(def.icon, color: def.color, size: 16.sp),
          SizedBox(height: 4.h),
          Text('$count',
              style: TextStyle(color: def.color, fontSize: 15.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 2.h),
          Text(def.display,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 9.sp)),
        ],
      ),
    );
  }
}

// ── Admin bottom-nav item ─────────────────────────────────────────────────────

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AdminNavItem({required this.icon, required this.label, required this.selected, required this.onTap});

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
          color: selected ? _cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _bg : Colors.grey, size: 22.sp),
            if (selected) ...[
              SizedBox(width: 6.w),
              Text(label,
                  style: TextStyle(color: _bg, fontWeight: FontWeight.w600, fontSize: 13.sp)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── User Tile ─────────────────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final dynamic user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({required this.user, required this.onEdit, required this.onDelete});

  Color _roleColor(String role) => switch (role) {
        'admin' => _purple,
        'doctor' => Colors.blueAccent,
        _ => _green,
      };

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(user.role);
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Text(
                user.role,
                style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
            SizedBox(width: 4.w),
            _IconBtn(icon: Icons.edit_rounded, color: _cyan, onTap: onEdit),
            _IconBtn(icon: Icons.delete_rounded, color: Colors.redAccent, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;
  const _NeonButton({required this.label, required this.color, required this.onTap, this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? color,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
