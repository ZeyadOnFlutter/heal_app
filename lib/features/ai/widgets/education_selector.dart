import 'package:flutter/material.dart';

class EducationSelectorWidget extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const EducationSelectorWidget({Key? key, required this.initialValue, required this.onChanged})
    : super(key: key);

  @override
  State<EducationSelectorWidget> createState() => _EducationSelectorWidgetState();
}

class _EducationSelectorWidgetState extends State<EducationSelectorWidget> {
  late int _value;

  final List<String> _educationLevels = [
    'Never attended school',
    'Elementary (Grades 1-8)',
    'Some high school (Grades 9-11)',
    'High school graduate',
    'Some college',
    'College graduate',
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Education Level', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: List.generate(6, (index) {
            return DropdownMenuItem(value: index + 1, child: Text(_educationLevels[index]));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() => _value = value);
              widget.onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
