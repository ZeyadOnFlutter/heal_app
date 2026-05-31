import 'package:flutter/material.dart';

class IncomeSelectorWidget extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const IncomeSelectorWidget({Key? key, required this.initialValue, required this.onChanged})
    : super(key: key);

  @override
  State<IncomeSelectorWidget> createState() => _IncomeSelectorWidgetState();
}

class _IncomeSelectorWidgetState extends State<IncomeSelectorWidget> {
  late int _value;

  final List<String> _incomeRanges = [
    'Less than \$10,000',
    '\$10,000 - \$15,000',
    '\$15,000 - \$20,000',
    '\$20,000 - \$25,000',
    '\$25,000 - \$35,000',
    '\$35,000 - \$50,000',
    '\$50,000 - \$75,000',
    '\$75,000 or more',
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
        const Text('Annual Income', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: List.generate(8, (index) {
            return DropdownMenuItem(value: index + 1, child: Text(_incomeRanges[index]));
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
