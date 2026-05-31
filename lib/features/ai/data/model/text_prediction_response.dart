class TextPredictionResponse {
  final String prediction;
  final double finalScore; // 0.0 – 1.0

  TextPredictionResponse({required this.prediction, required this.finalScore});

  factory TextPredictionResponse.fromJson(Map<String, dynamic> json) {
    return TextPredictionResponse(
      prediction: json['prediction']?.toString() ?? '',
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get percentage => finalScore * 100;

  DiseaseDetail toDiseaseDetail() =>
      DiseaseDetail(percentage: percentage, matchedSymptoms: const []);
}

class DiseaseDetail {
  final double percentage;
  final List<String> matchedSymptoms;

  DiseaseDetail({required this.percentage, required this.matchedSymptoms});
}
