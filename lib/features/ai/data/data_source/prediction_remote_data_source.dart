import 'dart:io';

import '../model/prediction_response.dart';
import '../model/health_data_model.dart';
import '../model/text_prediction_response.dart';

abstract class PredictionRemoteDataSource {
  Future<PredictionResponse> predictImage(File imageFile);
  Future<PredictionResponse> predictHealthData(HealthDataModel healthData);
  Future<PredictionResponse> predictSkinCancerImage(File imageFile);
  Future<PredictionResponse> predictSkinCancerSurvey(Map<String, dynamic> surveyData);
  Future<TextPredictionResponse> predictFromText(String text);
}
