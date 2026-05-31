import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/api_error_handler.dart';
import '../model/prediction_response.dart';
import '../model/health_data_model.dart';
import '../model/text_prediction_response.dart';
import 'prediction_remote_data_source.dart';

@LazySingleton(as: PredictionRemoteDataSource)
class PredictionApiDataSource implements PredictionRemoteDataSource {
  final Dio _mainDio;
  final Dio _predictDio;
  final Dio _skinCancerDio;
  final Dio _skinCancerSurveyDio;
  final Dio _textPredictDio;

  PredictionApiDataSource(
    @Named('MainDio') this._mainDio,
    @Named('PredictDio') this._predictDio,
    @Named('SkinCancerDio') this._skinCancerDio,
    @Named('SkinCancerSurveyDio') this._skinCancerSurveyDio,
    @Named('TextPredictDio') this._textPredictDio,
  );

  Future<MultipartFile> _rawMultipart(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final filename = imageFile.path.split(RegExp(r'[\\/]')).last;
    final ext = filename.split('.').last.toLowerCase();
    final mimeSubtype = (ext == 'png') ? 'png' : 'jpeg';
    print('[Image] file: $filename | size: ${bytes.length} bytes | mime=image/$mimeSubtype');
    return MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: MediaType('image', mimeSubtype),
    );
  }

  void _logRequest(Dio dio, String endpoint, FormData formData) {
    print('[Request] POST ${dio.options.baseUrl}$endpoint');
    print('[Request] Headers: ${dio.options.headers}');
    print('[Request] Fields: ${formData.fields}');
    print('[Request] Files: ${formData.files.map((f) => '${f.key}=${f.value.filename}(${f.value.length}b)').toList()}');
  }

  @override
  Future<PredictionResponse> predictImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({'file': await _rawMultipart(imageFile)});
      _logRequest(_mainDio, ApiEndpoints.diabetesPredict, formData);
      final response = await _mainDio.post(ApiEndpoints.diabetesPredict, data: formData);
      print('[Diabetes Image] Response: ${response.data}');
      return PredictionResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('[Diabetes Image] Error: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<PredictionResponse> predictHealthData(HealthDataModel healthData) async {
    try {
      final body = healthData.toJson();
      print('Diabetes Survey Request: $body');
      final response = await _predictDio.post(ApiEndpoints.diabetesPredict, data: body);
      print('Diabetes Survey Response: ${response.data}');
      return PredictionResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Diabetes Survey Error: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<PredictionResponse> predictSkinCancerImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({'file': await _rawMultipart(imageFile)});
      _logRequest(_skinCancerDio, ApiEndpoints.skinCancerPredict, formData);
      final response = await _skinCancerDio.post(ApiEndpoints.skinCancerPredict, data: formData);
      print('[SkinCancer Image] Response: ${response.data}');
      return PredictionResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('[SkinCancer Image] Error: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<PredictionResponse> predictSkinCancerSurvey(Map<String, dynamic> surveyData) async {
    try {
      final response = await _skinCancerSurveyDio.post(
        ApiEndpoints.skinCancerSurveyPredict,
        data: surveyData,
      );
      print('Skin Cancer Survey Response: ${response.data}');
      return PredictionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<TextPredictionResponse> predictFromText(String text) async {
    try {
      final response = await _textPredictDio.post(ApiEndpoints.textPredict, data: {'text': text});
      return TextPredictionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
