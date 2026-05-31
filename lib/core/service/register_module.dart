import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../shared/constants/constants.dart';

@module
abstract class RegisterModule {
  @singleton
  @Named('MainDio')
  Dio get mainDio =>
      Dio(BaseOptions(baseUrl: Constants().devBaseUrl, receiveDataWhenStatusError: true));

  @singleton
  @Named('PredictDio')
  Dio get predictDio =>
      Dio(BaseOptions(baseUrl: Constants().predictBaseUrl, receiveDataWhenStatusError: true));

  @singleton
  @Named('SkinCancerDio')
  Dio get skincancerDio =>
      Dio(BaseOptions(baseUrl: Constants().skincancerBaseUrl, receiveDataWhenStatusError: true));

  @singleton
  @Named('SkinCancerSurveyDio')
  Dio get skincancerSurveyDio => Dio(
    BaseOptions(baseUrl: Constants().skincancerSurveyBaseUrl, receiveDataWhenStatusError: true),
  );

  @singleton
  @Named('TextPredictDio')
  Dio get textPredictDio =>
      Dio(BaseOptions(baseUrl: Constants().textPredictBaseUrl, receiveDataWhenStatusError: true));

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
