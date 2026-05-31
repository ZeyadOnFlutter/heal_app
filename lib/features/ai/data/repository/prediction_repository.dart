import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/faliure.dart';
import '../../../auth/data/data_source/firebase_data_source/firebase_auth_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../data_source/prediction_remote_data_source.dart';
import '../model/prediction_response.dart';
import '../model/health_data_model.dart';
import '../model/text_prediction_response.dart';

@lazySingleton
class PredictionRepository {
  final PredictionRemoteDataSource _dataSource;
  final FirebaseAuthDataSource _firebaseDataSource;
  final FirebaseAuth _auth;

  PredictionRepository(this._dataSource, this._firebaseDataSource, this._auth);

  bool _isRemoteUrl(String url) {
    final normalized = url.toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  Future<String> _uploadImageToStorage(File imageFile, String userId) async {
    final fileName = imageFile.path.split(RegExp(r'[\\/]+')).last;
    final storageRef = FirebaseStorage.instance
        .ref('users/$userId/analysis_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final snapshot = await storageRef.putFile(imageFile);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadImageToStorage(File imageFile, String userId) async {
    return _uploadImageToStorage(imageFile, userId);
  }

  Future<Either<Failure, PredictionResponse>> predictImage(File imageFile, String imageUrl) async {
    try {
      final response = await _dataSource.predictImage(imageFile);
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        var recordedImageUrl = imageUrl;
        if (!_isRemoteUrl(imageUrl)) {
          try {
            recordedImageUrl = await _uploadImageToStorage(imageFile, userId);
          } catch (e) {
            print('[PredictionRepository] Firebase Storage upload failed: $e');
          }
        }
        final record = DiabetesRecord(
          imageUrl: recordedImageUrl,
          prediction: response.prediction,
          probabilityNonDiabetes: response.probability,
          timestamp: DateTime.now(),
        );
        await _firebaseDataSource.addDiabetesRecord(userId, record);
      }
      return Right(response);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, PredictionResponse>> predictHealthData(HealthDataModel healthData) async {
    try {
      final response = await _dataSource.predictHealthData(healthData);
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final survey = DiabetesSurvey(
          diabetes: response.prediction,
          probability: response.probability,
          timestamp: DateTime.now(),
          surveyData: healthData.toJson(),
        );
        await _firebaseDataSource.addDiabetesSurvey(userId, survey);
      }
      return Right(response);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, PredictionResponse>> predictSkinCancerImage(
    File imageFile,
    String imageUrl,
  ) async {
    try {
      final response = await _dataSource.predictSkinCancerImage(imageFile);
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        var recordedImageUrl = imageUrl;
        if (!_isRemoteUrl(imageUrl)) {
          try {
            recordedImageUrl = await _uploadImageToStorage(imageFile, userId);
          } catch (e) {
            print('[PredictionRepository] Firebase Storage upload failed: $e');
          }
        }
        final record = SkinCancerRecord(
          imageUrl: recordedImageUrl,
          predictedClass: response.prediction,
          confidence: response.probability,
          timestamp: DateTime.now(),
        );
        await _firebaseDataSource.addSkinCancerRecord(userId, record);
      }
      return Right(response);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, PredictionResponse>> predictSkinCancerSurvey(
    Map<String, dynamic> surveyData,
  ) async {
    try {
      final response = await _dataSource.predictSkinCancerSurvey(surveyData);
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final survey = SkinCancerSurvey(
          riskLevel: response.prediction,
          riskScore: response.probability,
          timestamp: DateTime.now(),
          surveyData: surveyData,
        );
        await _firebaseDataSource.addSkinCancerSurvey(userId, survey);
      }
      return Right(response);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, TextPredictionResponse>> predictFromText(String text) async {
    try {
      final response = await _dataSource.predictFromText(text);
      return Right(response);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<void> saveCombinedResult({
    required String disease,
    required String textDescription,
    required Map<String, dynamic> imageRecord,
    required Map<String, dynamic> surveyRecord,
    required Map<String, dynamic> nlpRecord,
    required double finalScore,
    required double imgScore,
    required double surveyScore,
    required double nlpScore,
    String predictionMode = 'precise',
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firebaseDataSource.addCombinedResult(
      userId,
      CombinedAnalysisResult(
        disease: disease,
        textDescription: textDescription,
        imageRecord: imageRecord,
        surveyRecord: surveyRecord,
        nlpRecord: nlpRecord,
        finalScore: finalScore,
        imgScore: imgScore,
        surveyScore: surveyScore,
        nlpScore: nlpScore,
        timestamp: DateTime.now(),
        predictionMode: predictionMode,
      ),
    );
  }
}

