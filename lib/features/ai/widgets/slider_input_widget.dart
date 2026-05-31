import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SliderInputWidget extends StatefulWidget {
  final String label;
  final double min;
  final double max;
  final double initialValue;
  final Function(double) onChanged;
  final Color color;

  const SliderInputWidget({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    this.color = Colors.teal,
  });

  @override
  State<SliderInputWidget> createState() => _SliderInputWidgetState();
}

class _SliderInputWidgetState extends State<SliderInputWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4)),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _value.toInt().toString(),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: widget.color),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color.withOpacity(0.15),
              thumbColor: widget.color,
              overlayColor: widget.color.withOpacity(0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: _value,
              min: widget.min,
              max: widget.max,
              divisions: (widget.max - widget.min).toInt(),
              onChanged: (v) {
                setState(() => _value = v);
                widget.onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.min.toInt().toString(), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
              Text(widget.max.toInt().toString(), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
