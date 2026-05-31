import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/service/service_locator.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';
import 'text_prediction_screen.dart';

class SkinCancerSurveyScreen extends StatefulWidget {
  const SkinCancerSurveyScreen({super.key});

  @override
  State<SkinCancerSurveyScreen> createState() => _SkinCancerSurveyScreenState();
}

class _SkinCancerSurveyScreenState extends State<SkinCancerSurveyScreen> {
  static const _color = Color(0xFF6A1B9A);

  late final PredictionCubit _predictionCubit;

  // Q1
  int _age = 30;
  // Q1b
  String _skinTone = 'Fair';
  // Q2
  String _hairColor = 'Black';
  // Q3
  String _freckles = 'None';
  // Q4
  String _numberOfMoles = '0-10';
  // Q5
  String _molesLarger5mm = 'None';
  // Q6
  String _changingMole = 'No';
  // Q7
  String _newGrowth = 'No';
  // Q8
  String _skinBurn = 'Never';
  // Q9
  String _tanningAbility = 'Tans easily and deeply';
  // Q10
  String _sunburnsChildhood = 'None';
  // Q11
  String _severeSunburn = 'No';
  // Q12
  String _dailySunExposure = 'Less than 1 hour';
  // Q13
  String _outdoorWork = 'Rarely';
  // Q14 (sunscreen)
  String _useSunscreen = 'Rarely';
  // Q15 (tanning bed)
  String _tanningBed = 'Never';
  // Q15
  String _yearsTanningBed = 'Never used';
  // Q16
  String _personalHistory = 'No';
  // Q17
  String _familyHistory = 'None';
  // Q18
  String _immunosuppressive = 'No';
  // Q19
  String _radiationTherapy = 'No';
  // Q20
  String _geographicUV = 'Low UV region';
  // Q21
  String _yearsHighUV = 'Never';
  // Q22
  String _skinSelfCheck = 'Monthly';
  // Q23
  String _dermatologist = 'Annually';
  // Q24
  String _dietAntioxidants = 'Often';

  @override
  void initState() {
    super.initState();
    _predictionCubit = getIt<PredictionCubit>();
  }

  void _submitForm() {
    _predictionCubit.predictSkinCancerSurvey({
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
    });
  }

  void _showResultSheet(PredictionSuccess state) {
    final riskLevel = state.prediction;
    final isHigh = riskLevel == 'High Risk';
    final isMod = riskLevel == 'Moderate Risk';
    final resultColor = isHigh ? Colors.red : isMod ? Colors.orange : Colors.green;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 72.w, height: 72.w,
              decoration: BoxDecoration(color: resultColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(
                isHigh ? Icons.warning_rounded : isMod ? Icons.info_rounded : Icons.check_circle_rounded,
                color: resultColor, size: 38.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text('Analysis Complete', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            SizedBox(height: 6.h),
            Text(
              riskLevel,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: resultColor),
            ),
            SizedBox(height: 6.h),
            if (state.message.isNotEmpty)
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TextPredictionScreen(filterDisease: 'skin cancer')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
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
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4)),
          SizedBox(height: 10.h),
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: _color)),
            ),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o.toString(), style: TextStyle(fontSize: 13.sp)))).toList(),
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
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4)),
          SizedBox(height: 12.h),
          Row(
            children: ['No', 'Yes'].map((opt) {
              final selected = value == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => onChanged(opt)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: opt == 'No' ? 4.w : 0, left: opt == 'Yes' ? 4.w : 0),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected ? _color : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: selected ? _color : Colors.grey.shade300),
                    ),
                    child: Text(opt, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey.shade600)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, color: _color, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _predictionCubit,
      child: BlocListener<PredictionCubit, PredictionState>(
        listener: (context, state) {
          if (state is PredictionSuccess && ModalRoute.of(context)?.isCurrent == true) {
            _showResultSheet(state);
          } else if (state is PredictionError && ModalRoute.of(context)?.isCurrent == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
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
                            Text('Skin Cancer Survey', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Answer honestly for best results', style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
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
                    // ── Demographics ─────────────────────────────
                    _section('Demographics', Icons.person_rounded),
                    SizedBox(height: 12.h),

                    // Q1 Age
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
                          Text('1. How old are you?', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                          SizedBox(height: 10.h),
                          TextFormField(
                            initialValue: _age.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter age (e.g. 34)',
                              filled: true, fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: _color)),
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

                    // Q2
                    _dropdown('2. What is your natural hair color?', _hairColor,
                      ['Black', 'Red', 'Blonde', 'Light Brown', 'Dark Brown'],
                      (v) => _hairColor = v),
                    SizedBox(height: 10.h),

                    // Q1b Skin tone
                    _dropdown('Skin Tone', _skinTone,
                      ['Very Fair', 'Fair', 'Olive', 'Brown', 'Dark'],
                      (v) => _skinTone = v),
                    SizedBox(height: 24.h),

                    // ── Physical Traits ───────────────────────────
                    _section('Physical Traits', Icons.face_rounded),
                    SizedBox(height: 12.h),

                    // Q3
                    _dropdown('3. Do you have freckles?', _freckles,
                      ['None', 'Few', 'Moderate', 'Many'],
                      (v) => _freckles = v),
                    SizedBox(height: 10.h),

                    // Q4
                    _dropdown('4. How many moles do you have on your body?', _numberOfMoles,
                      ['0-10', '11-25', '26-50', '51-100', 'More than 100'],
                      (v) => _numberOfMoles = v),
                    SizedBox(height: 10.h),

                    // Q5
                    _dropdown('5. How many of your moles are larger than 5mm?', _molesLarger5mm,
                      ['None', '1-2', '3-5', 'More than 5'],
                      (v) => _molesLarger5mm = v),
                    SizedBox(height: 24.h),

                    // ── Symptoms ──────────────────────────────────
                    _section('Symptoms', Icons.medical_information_rounded),
                    SizedBox(height: 12.h),

                    // Q6
                    _yesNo('6. Do you have a mole or skin spot that has been changing in size, shape, or color?',
                      _changingMole, (v) => _changingMole = v),
                    SizedBox(height: 10.h),

                    // Q7
                    _yesNo('7. Have you noticed any new or unusual skin growths recently?',
                      _newGrowth, (v) => _newGrowth = v),
                    SizedBox(height: 24.h),

                    // ── Sun Exposure ──────────────────────────────
                    _section('Sun Exposure', Icons.wb_sunny_rounded),
                    SizedBox(height: 12.h),

                    // Q8
                    _dropdown('8. How easily does your skin burn in the sun?', _skinBurn,
                      ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
                      (v) => _skinBurn = v),
                    SizedBox(height: 10.h),

                    // Q9
                    _dropdown('9. How well does your skin tan?', _tanningAbility,
                      ['Tans easily and deeply', 'Tans gradually', 'Rarely tans', 'Never tans'],
                      (v) => _tanningAbility = v),
                    SizedBox(height: 10.h),

                    // Q10
                    _dropdown('10. How many times were you sunburned as a child?', _sunburnsChildhood,
                      ['None', '1-2', '3-5', 'More than 5'],
                      (v) => _sunburnsChildhood = v),
                    SizedBox(height: 10.h),

                    // Q11
                    _yesNo('11. Have you ever had a severe, blistering sunburn?',
                      _severeSunburn, (v) => _severeSunburn = v),
                    SizedBox(height: 10.h),

                    // Q12
                    _dropdown('12. On average, how many hours per day are you exposed to the sun?', _dailySunExposure,
                      ['Less than 1 hour', '1-3 hours', '3-6 hours', 'More than 6 hours'],
                      (v) => _dailySunExposure = v),
                    SizedBox(height: 10.h),

                    // Q13
                    _dropdown('13. How often do you work or spend leisure time outdoors?', _outdoorWork,
                      ['Rarely', 'Sometimes', 'Often', 'Daily'],
                      (v) => _outdoorWork = v),
                    SizedBox(height: 24.h),

                    // ── Protection ────────────────────────────────
                    _section('Protection', Icons.shield_rounded),
                    SizedBox(height: 12.h),

                    // Sunscreen
                    _dropdown('How often do you use sunscreen?', _useSunscreen,
                      ['Always (SPF 30+)', 'Usually (SPF 15-29)', 'Sometimes', 'Rarely', 'Never'],
                      (v) => _useSunscreen = v),
                    SizedBox(height: 10.h),

                    // Q14
                    _dropdown('14. How often do you use a tanning bed?', _tanningBed,
                      ['Never', 'Occasionally', 'Regularly (monthly)', 'Frequently (weekly)'],
                      (v) => _tanningBed = v),
                    SizedBox(height: 10.h),

                    // Q15
                    _dropdown('15. How many years have you used tanning beds in total?', _yearsTanningBed,
                      ['Never used', 'Less than 1 year', '1-5 years', 'More than 5 years'],
                      (v) => _yearsTanningBed = v),
                    SizedBox(height: 24.h),

                    // ── Medical History ───────────────────────────
                    _section('Medical History', Icons.medical_services_rounded),
                    SizedBox(height: 12.h),

                    // Q16
                    _yesNo('16. Have you personally been diagnosed with skin cancer before?',
                      _personalHistory, (v) => _personalHistory = v),
                    SizedBox(height: 10.h),

                    // Q17
                    _dropdown('17. Has anyone in your family been diagnosed with skin cancer?', _familyHistory,
                      ['None', 'One relative', 'Two or more relatives'],
                      (v) => _familyHistory = v),
                    SizedBox(height: 10.h),

                    // Q18
                    _yesNo('18. Are you currently taking medication that suppresses your immune system?',
                      _immunosuppressive, (v) => _immunosuppressive = v),
                    SizedBox(height: 10.h),

                    // Q19
                    _yesNo('19. Have you ever received radiation therapy?',
                      _radiationTherapy, (v) => _radiationTherapy = v),
                    SizedBox(height: 24.h),

                    // ── Location & Lifestyle ──────────────────────
                    _section('Location & Lifestyle', Icons.location_on_rounded),
                    SizedBox(height: 12.h),

                    // Q20
                    _dropdown('20. What level of UV exposure does the region you live in get?', _geographicUV,
                      ['Low UV region', 'Moderate UV region', 'High UV region'],
                      (v) => _geographicUV = v),
                    SizedBox(height: 10.h),

                    // Q21
                    _dropdown('21. How long have you lived in a high UV area?', _yearsHighUV,
                      ['Never', 'Less than 5 years', '5-15 years', 'More than 15 years'],
                      (v) => _yearsHighUV = v),
                    SizedBox(height: 10.h),

                    // Q22
                    _dropdown('22. How often do you check your own skin for new spots or changes?', _skinSelfCheck,
                      ['Monthly', 'Every few months', 'Once a year', 'Rarely', 'Never'],
                      (v) => _skinSelfCheck = v),
                    SizedBox(height: 10.h),

                    // Q23
                    _dropdown('23. How often do you visit a dermatologist?', _dermatologist,
                      ['More than once a year', 'Annually', 'Once every few years', 'Never'],
                      (v) => _dermatologist = v),
                    SizedBox(height: 10.h),

                    // Q24
                    _dropdown('24. How often do you eat foods rich in antioxidants?', _dietAntioxidants,
                      ['Often', 'Sometimes', 'Rarely', 'Never'],
                      (v) => _dietAntioxidants = v),

                    SizedBox(height: 32.h),

                    BlocBuilder<PredictionCubit, PredictionState>(
                      builder: (context, state) {
                        final loading = state is PredictionLoading;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)]),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [BoxShadow(color: _color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: Size(double.infinity, 54.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                                      SizedBox(width: 8.w),
                                      Text('Analyze Survey', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
