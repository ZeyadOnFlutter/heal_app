import 'package:flutter/material.dart';
import '../data/model/text_prediction_response.dart';
import 'diabetes_detail_screen.dart';
import 'skin_cancer_detail_screen.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final TextPredictionResponse response;

  const DiseaseDetailScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final prediction = response.prediction;
    final percentage = response.percentage;
    final normalized = prediction.toLowerCase().replaceAll(' ', '');

    final color = normalized == 'skincancer' ? Colors.brown : Colors.blue;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results'), backgroundColor: Colors.teal),
      body: prediction.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'No matching conditions found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your symptoms don\'t match our database',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Possible Condition:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: InkWell(
                    onTap: () {
                      final detail = response.toDiseaseDetail();
                      if (normalized == 'diabetes') {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DiabetesDetailScreen(detail: detail)));
                      } else if (normalized == 'skincancer') {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SkinCancerDetailScreen(detail: detail)));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              prediction.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
