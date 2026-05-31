import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/service/service_locator.dart';
import '../viewmodel/prediction_cubit.dart';
import '../viewmodel/prediction_state.dart';
import 'disease_detail_screen.dart';
import 'diabetes_detail_screen.dart';
import 'skin_cancer_detail_screen.dart';

class TextPredictionScreen extends StatefulWidget {
  final String? filterDisease;
  const TextPredictionScreen({Key? key, this.filterDisease}) : super(key: key);

  @override
  State<TextPredictionScreen> createState() => _TextPredictionScreenState();
}

class _TextPredictionScreenState extends State<TextPredictionScreen> {
  final _textController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Symptom Analysis'),
          backgroundColor: Colors.teal,
        ),
        body: BlocListener<PredictionCubit, PredictionState>(
          listener: (context, state) {
            if (state is TextPredictionSuccess) {
              if (widget.filterDisease != null) {
                final normalizedFilter =
                    widget.filterDisease!.toLowerCase().replaceAll(' ', '');
                final normalizedPrediction =
                    state.response.prediction.toLowerCase().replaceAll(' ', '');

                if (normalizedPrediction == normalizedFilter) {
                  final detail = state.response.toDiseaseDetail();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        if (normalizedFilter == 'skincancer') {
                          return SkinCancerDetailScreen(detail: detail);
                        }
                        return DiabetesDetailScreen(detail: detail);
                      },
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No Match Found'),
                      content: Text(
                        'Your symptoms don\'t match ${widget.filterDisease} indicators. Please try describing your symptoms in more detail or consult a healthcare professional.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiseaseDetailScreen(response: state.response),
                  ),
                );
              }
            } else if (state is PredictionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Describe Your Symptoms',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us how you\'re feeling in your own words',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'e.g., I am really tired and feel weak...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<PredictionCubit, PredictionState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is PredictionLoading
                          ? null
                          : () {
                              if (_textController.text.trim().isNotEmpty) {
                                _cubit.predictFromText(_textController.text.trim());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is PredictionLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Analyze Symptoms',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
