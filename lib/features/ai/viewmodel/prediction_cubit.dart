import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../data/repository/prediction_repository.dart';
import '../data/model/health_data_model.dart';
import 'prediction_state.dart';

@lazySingleton
class PredictionCubit extends Cubit<PredictionState> {
  final PredictionRepository _repository;

  PredictionCubit(this._repository) : super(PredictionInitial());

  Future<void> predictImage(File imageFile, String imageUrl) async {
    emit(PredictionLoading());
    final response = await _repository.predictImage(imageFile, imageUrl);
    response.fold(
      (failure) => emit(PredictionError(failure.message)),
      (predictionResponse) => emit(
        PredictionSuccess(
          predictionResponse.prediction,
          probability: predictionResponse.probability,
          message: predictionResponse.message,
        ),
      ),
    );
  }

  Future<void> predictHealthData(HealthDataModel healthData) async {
    emit(PredictionLoading());
    final response = await _repository.predictHealthData(healthData);
    response.fold(
      (failure) => emit(PredictionError(failure.message)),
      (predictionResponse) => emit(
        PredictionSuccess(
          predictionResponse.prediction,
          probability: predictionResponse.probability,
          message: predictionResponse.message,
        ),
      ),
    );
  }

  Future<void> predictSkinCancerImage(File imageFile, String imageUrl) async {
    emit(PredictionLoading());
    final response = await _repository.predictSkinCancerImage(imageFile, imageUrl);
    response.fold(
      (failure) => emit(PredictionError(failure.message)),
      (predictionResponse) => emit(
        PredictionSuccess(
          predictionResponse.prediction,
          probability: predictionResponse.probability,
          message: predictionResponse.message,
        ),
      ),
    );
  }

  Future<void> predictSkinCancerSurvey(Map<String, dynamic> surveyData) async {
    emit(PredictionLoading());
    final response = await _repository.predictSkinCancerSurvey(surveyData);
    response.fold(
      (failure) => emit(PredictionError(failure.message)),
      (predictionResponse) => emit(
        PredictionSuccess(
          predictionResponse.prediction,
          probability: predictionResponse.probability,
          message: predictionResponse.message,
        ),
      ),
    );
  }

  Future<void> predictFromText(String text) async {
    emit(PredictionLoading());
    final response = await _repository.predictFromText(text);
    response.fold(
      (failure) => emit(PredictionError(failure.message)),
      (textResponse) => emit(TextPredictionSuccess(textResponse)),
    );
  }

  /// Calls all 3 APIs in parallel and computes weighted final score.
  /// Image 60% | Survey 30% | NLP 10%
  /// When predictionMode == 'fast', calls only the image API (score = imgScore).
  Future<void> runCombinedAnalysis({
    required String disease,
    required File imageFile,
    required Map<String, dynamic> surveyData,
    required String symptomText,
    String predictionMode = 'precise',
  }) async {
    emit(PredictionLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      var combinedImageUrl = imageFile.path;
      if (userId != null) {
        try {
          combinedImageUrl = await _repository.uploadImageToStorage(imageFile, userId);
        } catch (e) {
          print('[PredictionCubit] Image upload failed: $e');
        }
      }

      final imgFuture = disease == 'Skin Cancer'
          ? _repository.predictSkinCancerImage(imageFile, combinedImageUrl)
          : _repository.predictImage(imageFile, combinedImageUrl);

      final imgResp = await imgFuture;

      double imgScore = 0;
      Map<String, dynamic> imageRecord = {};
      imgResp.fold((f) => throw Exception(f.message), (r) {
        imgScore = r.probability * 100;
        if (disease == 'Skin Cancer') {
          imageRecord = {
            'imageUrl': combinedImageUrl,
            'predictedClass': r.prediction,
            'confidence': r.probability,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          imageRecord = {
            'imageUrl': combinedImageUrl,
            'prediction': r.prediction,
            'probabilityNonDiabetes': r.probability,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
      });

      double surveyScore = 0;
      Map<String, dynamic> surveyRecord = {};
      double nlpScore = 0;
      Map<String, dynamic> nlpRecord = {};
      double finalScore;

      if (predictionMode == 'fast') {
        finalScore = imgScore;
      } else {
        final surveyFuture = disease == 'Skin Cancer'
            ? _repository.predictSkinCancerSurvey(surveyData)
            : _repository.predictHealthData(HealthDataModel.fromJson(surveyData));
        final nlpFuture = _repository.predictFromText(symptomText);

        final surveyResp = await surveyFuture;
        final nlpResp = await nlpFuture;

        surveyResp.fold((f) => throw Exception(f.message), (r) {
          surveyScore = r.probability * 100;
          if (disease == 'Skin Cancer') {
            surveyRecord = {
              'riskLevel': r.prediction,
              'riskScore': r.probability,
              'surveyData': surveyData,
              'timestamp': DateTime.now().toIso8601String(),
            };
          } else {
            surveyRecord = {
              'diabetes': r.prediction,
              'probability': r.probability,
              'surveyData': surveyData,
              'timestamp': DateTime.now().toIso8601String(),
            };
          }
        });

        nlpResp.fold((f) => throw Exception(f.message), (r) {
          final normalizedDisease = disease.toLowerCase().replaceAll(' ', '');
          final normalizedPrediction = r.prediction.toLowerCase().replaceAll(' ', '');
          nlpScore = normalizedPrediction == normalizedDisease ? r.percentage : 0.0;
          nlpRecord = {
            'prediction': r.prediction,
            'final_score': r.finalScore,
            'percentage': nlpScore,
          };
        });

        finalScore = (imgScore * 0.60) + (surveyScore * 0.25) + (nlpScore * 0.15);
      }

      await _repository.saveCombinedResult(
        disease: disease,
        textDescription: symptomText,
        imageRecord: imageRecord,
        surveyRecord: surveyRecord,
        nlpRecord: nlpRecord,
        finalScore: finalScore.clamp(0, 100),
        imgScore: imgScore.clamp(0, 100),
        surveyScore: surveyScore.clamp(0, 100),
        nlpScore: nlpScore.clamp(0, 100),
        predictionMode: predictionMode,
      );

      emit(
        CombinedAnalysisSuccess(
          finalScore: finalScore.clamp(0, 100),
          imgScore: imgScore.clamp(0, 100),
          surveyScore: surveyScore.clamp(0, 100),
          nlpScore: nlpScore.clamp(0, 100),
          predictionMode: predictionMode,
        ),
      );
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }
}

