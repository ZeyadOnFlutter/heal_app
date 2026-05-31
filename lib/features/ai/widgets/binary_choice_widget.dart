import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BinaryChoiceWidget extends StatefulWidget {
  final String label;
  final int initialValue;
  final Function(int) onChanged;
  final String yesLabel;
  final String noLabel;
  final Color color;

  const BinaryChoiceWidget({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.yesLabel = 'Yes',
    this.noLabel = 'No',
    this.color = Colors.teal,
  });

  @override
  State<BinaryChoiceWidget> createState() => _BinaryChoiceWidgetState();
}

class _BinaryChoiceWidgetState extends State<BinaryChoiceWidget> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Widget _btn(String label, int val) {
    final selected = _value == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _value = val);
          widget.onChanged(val);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? widget.color : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: selected ? widget.color : Colors.grey.shade300),
          ),
          child: Text(
            label,
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
          Text(widget.label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _btn(widget.noLabel, 0),
              SizedBox(width: 8.w),
              _btn(widget.yesLabel, 1),
            ],
          ),
        ],
      ),
    );
  }
}
