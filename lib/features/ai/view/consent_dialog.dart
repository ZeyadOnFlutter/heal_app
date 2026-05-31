import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── ConsentService ────────────────────────────────────────────────────────────

class ConsentService {
  static Future<({bool? modelTraining, bool? doctorAccess})> getConsent(
      String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return (modelTraining: null, doctorAccess: null);
    final mt = data['consentModelTraining'];
    final da = data['consentDoctorAccess'];
    return (
      modelTraining: mt is bool ? mt : null,
      doctorAccess: da is bool ? da : null,
    );
  }

  static Future<void> saveConsent(
    String uid, {
    required bool modelTraining,
    required bool doctorAccess,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'consentModelTraining': modelTraining,
      'consentDoctorAccess': doctorAccess,
    });
  }
}

// ── ConsentDialog (first-time popup) ─────────────────────────────────────────

class ConsentDialog extends StatefulWidget {
  const ConsentDialog({super.key});

  /// Shows the dialog and returns whether the user confirmed.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const ConsentDialog(),
    );
  }

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _doctorAccess = true;
  bool _modelTraining = true;
  bool _saving = false;

  static const _accent = Color(0xFF1565C0);
  static const _green = Color(0xFF00C853);

  void _setModelTraining(bool v) {
    setState(() {
      _modelTraining = v;
      if (v) _doctorAccess = true; // model training requires doctor access
    });
  }

  void _setDoctorAccess(bool v) {
    setState(() {
      _doctorAccess = v;
      if (!v) _modelTraining = false; // revoking doctor access also revokes training
    });
  }

  Future<void> _confirm() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    await ConsentService.saveConsent(uid,
        modelTraining: _modelTraining, doctorAccess: _doctorAccess);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shield_outlined, color: Colors.white, size: 32.sp),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Your Privacy Choices',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Control how your health data is shared.\nYou can change this anytime in your Profile.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Toggles ──
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _ConsentTile(
                    icon: Icons.local_hospital_rounded,
                    color: _accent,
                    title: 'Doctor Review',
                    subtitle:
                        'Allow doctors to view your analysis results and provide personalised medical feedback.',
                    value: _doctorAccess,
                    onChanged: _setDoctorAccess,
                  ),
                  SizedBox(height: 12.h),
                  _ConsentTile(
                    icon: Icons.model_training_rounded,
                    color: _green,
                    title: 'AI Model Training',
                    subtitle:
                        'Help improve our diagnostic AI by allowing your anonymised data to be used for model training.',
                    note: 'Enabling this will also enable Doctor Review.',
                    value: _modelTraining,
                    onChanged: _setModelTraining,
                  ),
                  SizedBox(height: 24.h),

                  // ── Confirm button ──
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _saving ? null : _confirm,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: _saving
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Confirm My Choices',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
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

// ── ConsentSettingsCard (for Profile screen) ──────────────────────────────────

class ConsentSettingsCard extends StatefulWidget {
  final String uid;
  const ConsentSettingsCard({super.key, required this.uid});

  @override
  State<ConsentSettingsCard> createState() => _ConsentSettingsCardState();
}

class _ConsentSettingsCardState extends State<ConsentSettingsCard> {
  bool? _doctorAccess;
  bool? _modelTraining;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final consent = await ConsentService.getConsent(widget.uid);
    if (mounted) {
      setState(() {
        _doctorAccess = consent.doctorAccess ?? false;
        _modelTraining = consent.modelTraining ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_doctorAccess == null || _modelTraining == null) return;
    setState(() => _saving = true);
    await ConsentService.saveConsent(widget.uid,
        modelTraining: _modelTraining!, doctorAccess: _doctorAccess!);
    if (mounted) setState(() => _saving = false);
  }

  void _setModelTraining(bool v) {
    setState(() {
      _modelTraining = v;
      if (v) _doctorAccess = true;
    });
    _save();
  }

  void _setDoctorAccess(bool v) {
    setState(() {
      _doctorAccess = v;
      if (!v) _modelTraining = false;
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.privacy_tip_outlined,
                      color: const Color(0xFF1565C0), size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Privacy & Consent',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_saving)
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(
                        color: Color(0xFF1565C0), strokeWidth: 2),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Divider(color: Colors.grey.shade100, height: 1),

          if (_loading)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1565C0))),
            )
          else ...[
            _ProfileConsentRow(
              icon: Icons.local_hospital_rounded,
              color: const Color(0xFF1565C0),
              title: 'Doctor Review',
              subtitle: 'Allow doctors to view your results',
              value: _doctorAccess!,
              onChanged: _setDoctorAccess,
            ),
            Divider(color: Colors.grey.shade100, height: 1,
                indent: 16.w, endIndent: 16.w),
            _ProfileConsentRow(
              icon: Icons.model_training_rounded,
              color: const Color(0xFF00C853),
              title: 'AI Model Training',
              subtitle: 'Allow your data to help improve our AI',
              value: _modelTraining!,
              onChanged: _setModelTraining,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _ConsentTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? note;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.note,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.35) : Colors.grey.shade200,
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                SizedBox(height: 4.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade600, height: 1.4)),
                if (note != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 11.sp, color: Colors.orange.shade600),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(note!,
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.orange.shade600,
                                fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _ProfileConsentRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileConsentRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
