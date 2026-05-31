import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/data/models/user_model.dart';

class TrainingDataSection extends StatefulWidget {
  final CombinedAnalysisResult result;
  final String patientId;
  final bool consentModelTraining;

  const TrainingDataSection({
    super.key,
    required this.result,
    required this.patientId,
    this.consentModelTraining = false,
  });

  @override
  State<TrainingDataSection> createState() => _TrainingDataSectionState();
}

class _TrainingDataSectionState extends State<TrainingDataSection> {
  String? _selectedLabel;
  final _notesController = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  static const _accentColor = Color(0xFF00E5FF);
  static const _bgColor = Color(0xFF0A0E1A);
  static const _cardColor = Color(0xFF1A2235);
  static const _borderColor = Color(0xFF1E2D45);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Normalises the disease name into a Firestore-safe collection segment.
  /// e.g. "skin cancer" → "skin_cancer", "diabetes" → "diabetes".
  String get _diseaseKey => widget.result.disease.toLowerCase().replaceAll(' ', '_');

  List<_LabelOption> get _options {
    if (_diseaseKey == 'diabetes') {
      return const [
        _LabelOption(value: 'diabetic', display: 'Diabetic', icon: Icons.check_circle_outline_rounded, color: Colors.redAccent),
        _LabelOption(value: 'non_diabetic', display: 'Non-Diabetic', icon: Icons.cancel_outlined, color: Color(0xFF00E676)),
        _LabelOption(value: 'insufficient', display: 'Insufficient', icon: Icons.help_outline_rounded, color: Colors.orange),
      ];
    } else if (_diseaseKey == 'skin_cancer') {
      return const [
        _LabelOption(value: 'positive', display: 'Positive', icon: Icons.check_circle_outline_rounded, color: Colors.redAccent),
        _LabelOption(value: 'negative', display: 'Negative', icon: Icons.cancel_outlined, color: Color(0xFF00E676)),
        _LabelOption(value: 'insufficient', display: 'Insufficient', icon: Icons.help_outline_rounded, color: Colors.orange),
      ];
    } else {
      // Fallback for any future disease type.
      return const [
        _LabelOption(value: 'positive', display: 'Positive', icon: Icons.check_circle_outline_rounded, color: Colors.redAccent),
        _LabelOption(value: 'negative', display: 'Negative', icon: Icons.cancel_outlined, color: Color(0xFF00E676)),
        _LabelOption(value: 'insufficient', display: 'Insufficient', icon: Icons.help_outline_rounded, color: Colors.orange),
      ];
    }
  }

  /// Returns a canonical label-format string so `model_prediction` stored in
  /// Firestore always matches the values used for doctor labels.
  String _modelPrediction() {
    final img = widget.result.imageRecord;
    if (_diseaseKey == 'diabetes') {
      final raw = (img['prediction'] ?? '').toString().toLowerCase();
      return raw.contains('non') ? 'non_diabetic' : 'diabetic';
    }
    if (_diseaseKey == 'skin_cancer') {
      final cls = (img['predictedClass'] ?? '').toString().toUpperCase().trim();
      return (cls == 'MEL' || cls == 'BCC') ? 'positive' : 'negative';
    }
    return (img['prediction'] ?? img['predictedClass'] ?? img['anemiaStatus'] ?? '').toString();
  }

  double _confidence() {
    final conf = widget.result.imageRecord['confidence'];
    if (conf != null) return (conf as num).toDouble();
    return widget.result.imgScore;
  }

  Map<String, dynamic> _inputData() {
    final img = widget.result.imageRecord;
    return {
      'questionnaire': widget.result.surveyRecord['surveyData'] ?? {},
      'image_url': img['imageUrl'] ?? '',
      'free_text': widget.result.textDescription,
    };
  }

  Future<void> _save() async {
    if (_selectedLabel == null) return;
    setState(() => _saving = true);

    try {
      final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance
          .collection('training_data')
          .doc(_diseaseKey)
          .collection('records')
          .add({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'label': _selectedLabel,
        'model_prediction': _modelPrediction(),
        'confidence': _confidence(),
        'input_data': _inputData(),
        'notes': _notesController.text.trim(),
        'labeled_at': FieldValue.serverTimestamp(),
        'used_in_training': false,
      });

      setState(() {
        _saving = false;
        _saved = true;
      });
    } catch (_) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save training label'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.model_training_rounded, color: _accentColor, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                'AI Training Label',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (!widget.consentModelTraining)
            _buildNoConsentState()
          else if (_saved)
            _buildSuccessState()
          else
            _buildLabelingForm(),
        ],
      ),
    );
  }

  Widget _buildNoConsentState() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consent not given',
                style: TextStyle(color: Colors.orange, fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                'This patient has not consented to AI model training.',
                style: TextStyle(color: Colors.white38, fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.check_rounded, color: const Color(0xFF00E676), size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label saved',
              style: TextStyle(color: const Color(0xFF00E676), fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              'Thank you — this case will help improve the model.',
              style: TextStyle(color: Colors.white38, fontSize: 11.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabelingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your clinical assessment?',
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: _options
              .map((opt) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: opt != _options.last ? 6.w : 0),
                      child: _LabelChip(
                        option: opt,
                        selected: _selectedLabel == opt.value,
                        onTap: () => setState(() => _selectedLabel = opt.value),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: TextStyle(color: Colors.white, fontSize: 12.sp),
          decoration: InputDecoration(
            hintText: 'Optional notes...',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 12.sp),
            filled: true,
            fillColor: _cardColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: _accentColor),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: (_saving || _selectedLabel == null) ? null : _save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: _selectedLabel != null
                    ? _accentColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _selectedLabel != null
                      ? _accentColor.withValues(alpha: 0.5)
                      : _borderColor,
                ),
              ),
              alignment: Alignment.center,
              child: _saving
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        color: _accentColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save Label',
                      style: TextStyle(
                        color: _selectedLabel != null ? _accentColor : Colors.white24,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabelOption {
  final String value;
  final String display;
  final IconData icon;
  final Color color;
  const _LabelOption({required this.value, required this.display, required this.icon, required this.color});
}

class _LabelChip extends StatelessWidget {
  final _LabelOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LabelChip({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? option.color.withValues(alpha: 0.12) : const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? option.color.withValues(alpha: 0.6) : const Color(0xFF1E2D45),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, color: selected ? option.color : Colors.white24, size: 16.sp),
            SizedBox(height: 3.h),
            Text(
              option.display,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? option.color : Colors.white38,
                fontSize: 9.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
