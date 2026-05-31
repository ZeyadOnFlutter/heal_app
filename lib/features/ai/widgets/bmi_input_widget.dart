import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BMIInputWidget extends StatefulWidget {
  final double initialValue;
  final Function(double) onChanged;
  final Color color;

  const BMIInputWidget({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.color = Colors.blueAccent,
  });

  @override
  State<BMIInputWidget> createState() => _BMIInputWidgetState();
}

class _BMIInputWidgetState extends State<BMIInputWidget> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  double _bmi = 0.0;

  @override
  void initState() {
    super.initState();
    _bmi = widget.initialValue;
  }

  void _calculate() {
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    if (w != null && h != null && h > 0) {
      final hm = h / 100;
      setState(() => _bmi = double.parse((w / (hm * hm)).toStringAsFixed(1)));
      widget.onChanged(_bmi);
    }
  }

  String get _bmiCategory {
    if (_bmi <= 0) return '';
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    if (_bmi <= 0) return Colors.grey;
    if (_bmi < 18.5) return Colors.orange;
    if (_bmi < 25) return Colors.green;
    if (_bmi < 30) return Colors.orange;
    return Colors.red;
  }

  InputDecoration _inputDeco(String hint, String suffix) => InputDecoration(
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
          borderSide: BorderSide(color: widget.color),
        ),
      );

  @override
  Widget build(BuildContext context) {
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
          Text('Body Mass Index (BMI)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _weightCtrl,
                      decoration: _inputDeco('70', 'kg'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Height', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _heightCtrl,
                      decoration: _inputDeco('175', 'cm'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_bmi > 0) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _bmiColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _bmiColor.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your BMI', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                  Row(
                    children: [
                      Text(
                        _bmi.toString(),
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: _bmiColor),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _bmiColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(_bmiCategory, style: TextStyle(fontSize: 11.sp, color: _bmiColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }
}
