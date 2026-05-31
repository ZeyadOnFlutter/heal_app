import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/service/service_locator.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';
import '../widgets/analysis_shared_widgets.dart';
import 'analysis_result_screen.dart';

import 'analysis_history_screen.dart';

class SkinCancerAnalysisScreen extends StatefulWidget {
  final String predictionMode;

  const SkinCancerAnalysisScreen({super.key, this.predictionMode = 'precise'});

  @override
  State<SkinCancerAnalysisScreen> createState() => _SkinCancerAnalysisScreenState();
}

class _SkinCancerAnalysisScreenState extends State<SkinCancerAnalysisScreen> {
  static const _color = Color(0xFF6A1B9A);
  static const _disease = 'Skin Cancer';

  File? _image;
  final _textController = TextEditingController();
  late final PredictionCubit _cubit;

  // Survey state (same fields as SkinCancerSurveyScreen)
  int _age = 30;
  String _skinTone = 'Fair';
  String _hairColor = 'Black';
  String _freckles = 'None';
  String _numberOfMoles = '0-10';
  String _molesLarger5mm = 'None';
  String _changingMole = 'No';
  String _newGrowth = 'No';
  String _skinBurn = 'Never';
  String _tanningAbility = 'Tans easily and deeply';
  String _sunburnsChildhood = 'None';
  String _severeSunburn = 'No';
  String _dailySunExposure = 'Less than 1 hour';
  String _outdoorWork = 'Rarely';
  String _useSunscreen = 'Rarely';
  String _tanningBed = 'Never';
  String _yearsTanningBed = 'Never used';
  String _personalHistory = 'No';
  String _familyHistory = 'None';
  String _immunosuppressive = 'No';
  String _radiationTherapy = 'No';
  String _geographicUV = 'Low UV region';
  String _yearsHighUV = 'Never';
  String _skinSelfCheck = 'Monthly';
  String _dermatologist = 'Annually';
  String _dietAntioxidants = 'Often';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<PredictionCubit>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Map<String, dynamic> get _surveyData => {
    'age': _age,
    'skin_tone': _skinTone,
    'natural_hair_color': _hairColor,
    'freckles': _freckles,
    'number_of_moles': _numberOfMoles,
    'moles_larger_than_5mm': _molesLarger5mm,
    'changing_mole_or_lesion': _changingMole,
    'new_unusual_skin_growth': _newGrowth,
    'skin_easily_sunburned': _skinBurn,
    'tanning_ability': _tanningAbility,
    'sunburns_in_childhood': _sunburnsChildhood,
    'severe_blistering_sunburns_ever': _severeSunburn,
    'daily_sun_exposure_hours': _dailySunExposure,
    'outdoor_work_or_recreation': _outdoorWork,
    'use_of_sunscreen': _useSunscreen,
    'use_of_tanning_bed': _tanningBed,
    'years_of_tanning_bed_use': _yearsTanningBed,
    'personal_history_skin_cancer': _personalHistory,
    'family_history_skin_cancer': _familyHistory,
    'immunosuppressive_medication': _immunosuppressive,
    'radiation_therapy_history': _radiationTherapy,
    'geographic_location_uv': _geographicUV,
    'years_lived_in_high_uv_area': _yearsHighUV,
    'perform_skin_self_checks': _skinSelfCheck,
    'seen_dermatologist': _dermatologist,
    'diet_high_antioxidants': _dietAntioxidants,
  };

  void _analyze() {
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please upload an image')));
      return;
    }
    final isFast = widget.predictionMode == 'fast';
    if (!isFast && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please describe your symptoms')));
      return;
    }
    _cubit.runCombinedAnalysis(
      disease: _disease,
      imageFile: _image!,
      surveyData: _surveyData,
      symptomText: _textController.text.trim(),
      predictionMode: widget.predictionMode,
    );
  }

  Widget _dropdown<T>(String label, T value, List<T> options, void Function(T) onChanged) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4),
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _color),
              ),
            ),
            items: options
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(o.toString(), style: TextStyle(fontSize: 13.sp)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => onChanged(v as T)),
          ),
        ],
      ),
    );
  }

  Widget _yesNo(String label, String value, void Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4),
          ),
          SizedBox(height: 12.h),
          Row(
            children: ['No', 'Yes'].map((opt) {
              final selected = value == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => onChanged(opt)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: opt == 'No' ? 4.w : 0,
                      left: opt == 'Yes' ? 4.w : 0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected ? _color : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: selected ? _color : Colors.grey.shade300),
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<PredictionCubit, PredictionState>(
        listener: (context, state) {
          if (state is CombinedAnalysisSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnalysisResultScreen(
                  disease: _disease,
                  color: _color,
                  icon: '🔆',
                  result: state,
                ),
              ),
            );
          } else if (state is PredictionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150.h,
                pinned: true,
                backgroundColor: _color,
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
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AnalysisHistoryScreen(disease: _disease, color: _color, icon: '🔆'),
                    )),
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.history_rounded, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
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
                            Text('🔆', style: TextStyle(fontSize: 30.sp)),
                            SizedBox(height: 4.h),
                            Text(
                              'Skin Cancer Analysis',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Complete all sections for accurate results',
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
                    // ── Step 1: Image ──────────────────────────────
                    const StepHeader(step: '1', title: 'Upload Skin Image', color: _color),
                    SizedBox(height: 12.h),
                    AnalysisImagePicker(
                      image: _image,
                      color: _color,
                      samplePath: 'assets/images/skincancer.jpeg',
                      onPick: _pickImage,
                      onRemove: () => setState(() => _image = null),
                    ),

                    SizedBox(height: 28.h),

                    // ── Step 2: Survey (Precise only) ──────────────
                    if (widget.predictionMode != 'fast') ...[
                    const StepHeader(step: '2', title: 'Risk Factor Survey', color: _color),
                    SizedBox(height: 12.h),

                    // Age
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. How old are you?',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            initialValue: _age.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter age',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 14.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(color: _color),
                              ),
                            ),
                            onChanged: (v) {
                              final age = int.tryParse(v);
                              if (age != null && age >= 1 && age <= 120) setState(() => _age = age);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('2. Natural hair color?', _hairColor, [
                      'Black',
                      'Red',
                      'Blonde',
                      'Light Brown',
                      'Dark Brown',
                    ], (v) => _hairColor = v),
                    SizedBox(height: 10.h),
                    _dropdown('Skin Tone', _skinTone, [
                      'Very Fair',
                      'Fair',
                      'Olive',
                      'Brown',
                      'Dark',
                    ], (v) => _skinTone = v),
                    SizedBox(height: 10.h),
                    _dropdown('3. Do you have freckles?', _freckles, [
                      'None',
                      'Few',
                      'Moderate',
                      'Many',
                    ], (v) => _freckles = v),
                    SizedBox(height: 10.h),
                    _dropdown('4. How many moles on your body?', _numberOfMoles, [
                      '0-10',
                      '11-25',
                      '26-50',
                      '51-100',
                      'More than 100',
                    ], (v) => _numberOfMoles = v),
                    SizedBox(height: 10.h),
                    _dropdown('5. Moles larger than 5mm?', _molesLarger5mm, [
                      'None',
                      '1-2',
                      '3-5',
                      'More than 5',
                    ], (v) => _molesLarger5mm = v),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '6. Mole or skin spot changing in size, shape, or color?',
                      _changingMole,
                      (v) => _changingMole = v,
                    ),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '7. New or unusual skin growths recently?',
                      _newGrowth,
                      (v) => _newGrowth = v,
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('8. How easily does your skin burn?', _skinBurn, [
                      'Never',
                      'Rarely',
                      'Sometimes',
                      'Often',
                      'Always',
                    ], (v) => _skinBurn = v),
                    SizedBox(height: 10.h),
                    _dropdown('9. How well does your skin tan?', _tanningAbility, [
                      'Tans easily and deeply',
                      'Tans gradually',
                      'Rarely tans',
                      'Never tans',
                    ], (v) => _tanningAbility = v),
                    SizedBox(height: 10.h),
                    _dropdown('10. Sunburns as a child?', _sunburnsChildhood, [
                      'None',
                      '1-2',
                      '3-5',
                      'More than 5',
                    ], (v) => _sunburnsChildhood = v),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '11. Ever had a severe, blistering sunburn?',
                      _severeSunburn,
                      (v) => _severeSunburn = v,
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('12. Daily sun exposure hours?', _dailySunExposure, [
                      'Less than 1 hour',
                      '1-3 hours',
                      '3-6 hours',
                      'More than 6 hours',
                    ], (v) => _dailySunExposure = v),
                    SizedBox(height: 10.h),
                    _dropdown('13. Time spent outdoors?', _outdoorWork, [
                      'Rarely',
                      'Sometimes',
                      'Often',
                      'Daily',
                    ], (v) => _outdoorWork = v),
                    SizedBox(height: 10.h),
                    _dropdown('How often do you use sunscreen?', _useSunscreen, [
                      'Always (SPF 30+)',
                      'Usually (SPF 15-29)',
                      'Sometimes',
                      'Rarely',
                      'Never',
                    ], (v) => _useSunscreen = v),
                    SizedBox(height: 10.h),
                    _dropdown('14. Tanning bed use?', _tanningBed, [
                      'Never',
                      'Occasionally',
                      'Regularly (monthly)',
                      'Frequently (weekly)',
                    ], (v) => _tanningBed = v),
                    SizedBox(height: 10.h),
                    _dropdown('15. Years of tanning bed use?', _yearsTanningBed, [
                      'Never used',
                      'Less than 1 year',
                      '1-5 years',
                      'More than 5 years',
                    ], (v) => _yearsTanningBed = v),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '16. Personal history of skin cancer?',
                      _personalHistory,
                      (v) => _personalHistory = v,
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('17. Family history of skin cancer?', _familyHistory, [
                      'None',
                      'One relative',
                      'Two or more relatives',
                    ], (v) => _familyHistory = v),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '18. Taking immunosuppressive medication?',
                      _immunosuppressive,
                      (v) => _immunosuppressive = v,
                    ),
                    SizedBox(height: 10.h),
                    _yesNo(
                      '19. Ever received radiation therapy?',
                      _radiationTherapy,
                      (v) => _radiationTherapy = v,
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('20. UV level of your region?', _geographicUV, [
                      'Low UV region',
                      'Moderate UV region',
                      'High UV region',
                    ], (v) => _geographicUV = v),
                    SizedBox(height: 10.h),
                    _dropdown('21. Years lived in high UV area?', _yearsHighUV, [
                      'Never',
                      'Less than 5 years',
                      '5-15 years',
                      'More than 15 years',
                    ], (v) => _yearsHighUV = v),
                    SizedBox(height: 10.h),
                    _dropdown('22. How often do you check your skin?', _skinSelfCheck, [
                      'Monthly',
                      'Every few months',
                      'Once a year',
                      'Rarely',
                      'Never',
                    ], (v) => _skinSelfCheck = v),
                    SizedBox(height: 10.h),
                    _dropdown(
                      '23. How often do you visit a dermatologist?',
                      _dermatologist,
                      ['More than once a year', 'Annually', 'Once every few years', 'Never'],
                      (v) => _dermatologist = v,
                    ),
                    SizedBox(height: 10.h),
                    _dropdown('24. Diet rich in antioxidants?', _dietAntioxidants, [
                      'Often',
                      'Sometimes',
                      'Rarely',
                      'Never',
                    ], (v) => _dietAntioxidants = v),

                    SizedBox(height: 28.h),

                    // ── Step 3: Symptoms Text ──────────────────────
                    const StepHeader(step: '3', title: 'Describe Your Symptoms', color: _color),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'e.g., I noticed a dark spot on my arm that has been growing...',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(color: _color),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ] else
                      SizedBox(height: 32.h),

                    // ── Analyze Button ─────────────────────────────
                    BlocBuilder<PredictionCubit, PredictionState>(
                      builder: (context, state) {
                        final loading = state is PredictionLoading;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: _color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _analyze,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: Size(double.infinity, 54.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Analyze',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
