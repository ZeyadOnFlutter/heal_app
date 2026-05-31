import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/service/service_locator.dart';
import '../data/model/health_data_model.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';
import '../widgets/age_selector_widget.dart';
import '../widgets/binary_choice_widget.dart';
import '../widgets/bmi_input_widget.dart';
import '../widgets/slider_input_widget.dart';
import 'analysis_result_screen.dart';
import '../widgets/analysis_shared_widgets.dart';

import 'analysis_history_screen.dart';

class DiabetesAnalysisScreen extends StatefulWidget {
  final String predictionMode;

  const DiabetesAnalysisScreen({super.key, this.predictionMode = 'precise'});

  @override
  State<DiabetesAnalysisScreen> createState() => _DiabetesAnalysisScreenState();
}

class _DiabetesAnalysisScreenState extends State<DiabetesAnalysisScreen> {
  static const _color = Colors.blueAccent;
  static const _disease = 'Diabetes';

  File? _image;
  final _textController = TextEditingController();
  final _healthData = HealthDataModel();
  late final PredictionCubit _cubit;

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
      surveyData: _healthData.toJson(),
      symptomText: _textController.text.trim(),
      predictionMode: widget.predictionMode,
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
                  icon: '🔬',
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
                      builder: (_) => const AnalysisHistoryScreen(disease: _disease, color: _color, icon: '🔬'),
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
                              'Diabetes Analysis',
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
                    const StepHeader(step: '1', title: 'Upload Tongue Image', color: _color),
                    SizedBox(height: 12.h),
                    AnalysisImagePicker(
                      image: _image,
                      color: _color,
                      samplePath: 'assets/images/tounge.png',
                      onPick: _pickImage,
                      onRemove: () => setState(() => _image = null),
                    ),

                    SizedBox(height: 28.h),

                    // ── Step 2: Survey (Precise only) ──────────────
                    if (widget.predictionMode != 'fast') ...[
                      const StepHeader(step: '2', title: 'Health Survey', color: _color),
                      SizedBox(height: 12.h),
                      BMIInputWidget(
                        initialValue: _healthData.bmi,
                        onChanged: (v) => _healthData.bmi = v,
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      BinaryChoiceWidget(
                        label: 'Have you been told you have high blood pressure?',
                        initialValue: _healthData.highBP,
                        onChanged: (v) => _healthData.highBP = v,
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      BinaryChoiceWidget(
                        label: 'Have you been told your cholesterol is high?',
                        initialValue: _healthData.highChol,
                        onChanged: (v) => _healthData.highChol = v,
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      BinaryChoiceWidget(
                        label: 'Do you do physical activity or exercise?',
                        initialValue: _healthData.physActivity,
                        onChanged: (v) => _healthData.physActivity = v,
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      SliderInputWidget(
                        label: 'General health (1=Excellent, 5=Poor)',
                        min: 1,
                        max: 5,
                        initialValue: _healthData.genHlth.toDouble(),
                        onChanged: (v) => _healthData.genHlth = v.toInt(),
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      SliderInputWidget(
                        label: 'Days physical health was not good (0–30)',
                        min: 0,
                        max: 30,
                        initialValue: _healthData.physHlth.toDouble(),
                        onChanged: (v) => _healthData.physHlth = v.toInt(),
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      BinaryChoiceWidget(
                        label: 'Difficulty walking or climbing stairs?',
                        initialValue: _healthData.diffWalk,
                        onChanged: (v) => _healthData.diffWalk = v,
                        color: _color,
                      ),
                      SizedBox(height: 10.h),
                      AgeSelectorWidget(
                        initialValue: _healthData.age,
                        onChanged: (v) => _healthData.age = v,
                        color: _color,
                      ),
                      SizedBox(height: 28.h),

                      // ── Step 3: Symptoms Text ──────────────────────
                      const StepHeader(step: '3', title: 'Describe Your Symptoms', color: _color),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _textController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'e.g., I feel very thirsty, frequent urination, blurred vision...',
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
