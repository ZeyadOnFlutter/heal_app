import 'package:equatable/equatable.dart';
import '../data/model/text_prediction_response.dart';

abstract class PredictionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionSuccess extends PredictionState {
  final String prediction;
  final double probability;
  final String message;

  PredictionSuccess(this.prediction, {this.probability = 0.0, this.message = ''});

  @override
  List<Object?> get props => [prediction, probability, message];
}

class TextPredictionSuccess extends PredictionState {
  final TextPredictionResponse response;

  TextPredictionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PredictionError extends PredictionState {
  final String message;

  PredictionError(this.message);

  @override
  List<Object?> get props => [message];
}

class CombinedAnalysisSuccess extends PredictionState {
  final double finalScore;
  final double imgScore;
  final double surveyScore;
  final double nlpScore;
  final String predictionMode;

  CombinedAnalysisSuccess({
    required this.finalScore,
    required this.imgScore,
    required this.surveyScore,
    required this.nlpScore,
    this.predictionMode = 'precise',
  });

  @override
  List<Object?> get props => [finalScore, imgScore, surveyScore, nlpScore, predictionMode];
}
