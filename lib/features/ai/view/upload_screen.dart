import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';

class UploadScreen extends StatefulWidget {
  final String category;
  final String icon;
  final Color color;
  final String sampleImagePath;

  const UploadScreen({
    super.key,
    required this.category,
    required this.icon,
    required this.color,
    required this.sampleImagePath,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _analyzeImage() {
    if (_selectedImage == null) {
      _showSnack('Please upload an image first');
      return;
    }
    if (widget.category == 'Diabetes') {
      context.read<PredictionCubit>().predictImage(_selectedImage!, _selectedImage!.path);
    } else {
      context.read<PredictionCubit>().predictSkinCancerImage(_selectedImage!, _selectedImage!.path);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showResultSheet(PredictionSuccess state) {
    final isPositive = state.prediction == '1';
    final resultColor = isPositive ? Colors.red : Colors.green;
    final resultLabel = widget.category == 'Diabetes'
        ? (isPositive ? 'Diabetic' : 'Not Diabetic')
        : (isPositive ? 'Cancer Detected' : 'No Cancer Detected');

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
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.warning_rounded : Icons.check_circle_rounded,
                color: resultColor, size: 38.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text('Analysis Complete', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            SizedBox(height: 6.h),
            Text(
              resultLabel,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: resultColor),
            ),
            if (state.message.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Done', style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      body: BlocListener<PredictionCubit, PredictionState>(
        listener: (context, state) {
          if (state is PredictionSuccess) _showResultSheet(state);
          if (state is PredictionError) _showSnack('Error: ${state.message}');
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient App Bar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 160.h,
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
                      colors: [widget.color, widget.color.withOpacity(0.7)],
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
                          Text(widget.icon, style: TextStyle(fontSize: 32.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.category} Detection',
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Upload a photo for AI analysis',
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
                  // ── Info Banner ───────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: widget.color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: widget.color, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Match the sample photo below for accurate results',
                            style: TextStyle(fontSize: 13.sp, color: widget.color),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Sample Photo ──────────────────────────────────
                  _SectionLabel(label: 'Sample Photo'),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Image.asset(
                      widget.sampleImagePath,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Center(child: Icon(Icons.image_rounded, size: 50.sp, color: Colors.grey.shade400)),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Your Photo ────────────────────────────────────
                  _SectionLabel(label: 'Your Photo'),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 260.h,
                      decoration: BoxDecoration(
                        color: _selectedImage != null ? Colors.transparent : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: _selectedImage != null ? widget.color : Colors.grey.shade300,
                          width: _selectedImage != null ? 2 : 1.5,
                        ),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(_selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 10.h, right: 10.w,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedImage = null),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add_photo_alternate_rounded, size: 36.sp, color: widget.color),
                                ),
                                SizedBox(height: 12.h),
                                Text('Tap to upload from gallery', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                                SizedBox(height: 4.h),
                                Text('or use camera below', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Action Buttons ────────────────────────────────
                  BlocBuilder<PredictionCubit, PredictionState>(
                    builder: (context, state) {
                      final isBusy = _isLoading || state is PredictionLoading;
                      if (isBusy) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: CircularProgressIndicator(color: widget.color),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _OutlineBtn(
                                  label: 'Camera',
                                  icon: Icons.camera_alt_rounded,
                                  color: widget.color,
                                  onTap: () => _pickImage(ImageSource.camera),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _OutlineBtn(
                                  label: 'Gallery',
                                  icon: Icons.photo_library_rounded,
                                  color: widget.color,
                                  onTap: () => _pickImage(ImageSource.gallery),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedImage != null) ...[
                            SizedBox(height: 14.h),
                            SizedBox(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [widget.color, widget.color.withOpacity(0.75)],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _analyzeImage,
                                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                                  label: Text('Analyze Image', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
    );
  }
}
