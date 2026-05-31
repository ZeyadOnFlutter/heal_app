import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/service/service_locator.dart';
import '../data/model/health_data_model.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';
import '../widgets/age_selector_widget.dart';
import '../widgets/binary_choice_widget.dart';
import '../widgets/bmi_input_widget.dart';
import '../widgets/slider_input_widget.dart';
import 'text_prediction_screen.dart';

class HealthSurveyScreen extends StatefulWidget {
  const HealthSurveyScreen({super.key});

  @override
  State<HealthSurveyScreen> createState() => _HealthSurveyScreenState();
}

class _HealthSurveyScreenState extends State<HealthSurveyScreen> {
  final HealthDataModel _healthData = HealthDataModel();
  late final PredictionCubit _predictionCubit;

  static const _color = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _predictionCubit = getIt<PredictionCubit>();
  }

  void _submitForm() => _predictionCubit.predictHealthData(_healthData);

  void _showResultSheet(PredictionSuccess state) {
    final isDiabetic = state.prediction == '1';
    final resultColor = isDiabetic ? Colors.red : Colors.green;

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
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDiabetic ? Icons.warning_rounded : Icons.check_circle_rounded,
                color: resultColor,
                size: 38.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Analysis Complete',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
            SizedBox(height: 6.h),
            Text(
              isDiabetic ? 'Diabetic' : 'Not Diabetic',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: resultColor),
            ),
            SizedBox(height: 6.h),
            Text(
              'Probability: ${(state.probability * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
            ),
            if (state.message.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
              ),
            ],
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TextPredictionScreen(filterDisease: 'diabetes'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Gradient App Bar ────────────────────────────────
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
                        colors: [Color(0xFF1565C0), Colors.blueAccent],
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
                            Text('🔬', style: TextStyle(fontSize: 30.sp)),
                            SizedBox(height: 4.h),
                            Text(
                              'Diabetes Survey',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Answer honestly for best results',
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
                    const _SurveySection(
                      title: 'Body Measurements',
                      icon: Icons.monitor_weight_rounded,
                      color: _color,
                    ),
                    SizedBox(height: 12.h),
                    BMIInputWidget(
                      initialValue: _healthData.bmi,
                      onChanged: (v) => _healthData.bmi = v,
                      color: _color,
                    ),

                    SizedBox(height: 24.h),
                    const _SurveySection(
                      title: 'Medical History',
                      icon: Icons.medical_services_rounded,
                      color: _color,
                    ),
                    SizedBox(height: 12.h),
                    BinaryChoiceWidget(
                      label:
                          'Have you ever been told by a doctor that you have high blood pressure?',
                      initialValue: _healthData.highBP,
                      onChanged: (v) => _healthData.highBP = v,
                      color: _color,
                    ),
                    SizedBox(height: 10.h),
                    BinaryChoiceWidget(
                      label: 'Have you ever been told that your cholesterol is high?',
                      initialValue: _healthData.highChol,
                      onChanged: (v) => _healthData.highChol = v,
                      color: _color,
                    ),

                    SizedBox(height: 24.h),
                    const _SurveySection(
                      title: 'Lifestyle',
                      icon: Icons.directions_run_rounded,
                      color: _color,
                    ),
                    SizedBox(height: 12.h),
                    BinaryChoiceWidget(
                      label:
                          'During the past 30 days, have you done any physical activity or exercise?',
                      initialValue: _healthData.physActivity,
                      onChanged: (v) => _healthData.physActivity = v,
                      color: _color,
                    ),

                    SizedBox(height: 24.h),
                    const _SurveySection(
                      title: 'Health Status',
                      icon: Icons.favorite_rounded,
                      color: _color,
                    ),
                    SizedBox(height: 12.h),
                    SliderInputWidget(
                      label: 'How would you rate your general health? (1=Excellent, 5=Poor)',
                      min: 1,
                      max: 5,
                      initialValue: _healthData.genHlth.toDouble(),
                      onChanged: (v) => _healthData.genHlth = v.toInt(),
                      color: _color,
                    ),
                    SizedBox(height: 10.h),
                    SliderInputWidget(
                      label: 'For how many days was your physical health not good? (0–30)',
                      min: 0,
                      max: 30,
                      initialValue: _healthData.physHlth.toDouble(),
                      onChanged: (v) => _healthData.physHlth = v.toInt(),
                      color: _color,
                    ),
                    SizedBox(height: 10.h),
                    BinaryChoiceWidget(
                      label: 'Do you have serious difficulty walking or climbing stairs?',
                      initialValue: _healthData.diffWalk,
                      onChanged: (v) => _healthData.diffWalk = v,
                      color: _color,
                    ),

                    SizedBox(height: 24.h),
                    const _SurveySection(
                      title: 'Demographics',
                      icon: Icons.person_rounded,
                      color: _color,
                    ),
                    SizedBox(height: 12.h),
                    AgeSelectorWidget(
                      initialValue: _healthData.age,
                      onChanged: (v) => _healthData.age = v,
                      color: _color,
                    ),

                    SizedBox(height: 32.h),
                    BlocBuilder<PredictionCubit, PredictionState>(
                      builder: (context, state) {
                        final loading = state is PredictionLoading;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Colors.blueAccent],
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
                            onPressed: loading ? null : _submitForm,
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
                                        'Analyze Survey',
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

class _SurveySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SurveySection({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
