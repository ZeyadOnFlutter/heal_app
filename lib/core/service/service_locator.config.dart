// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:heal_app/core/service/register_module.dart' as _i155;
import 'package:heal_app/features/admin/data/admin_data_source.dart' as _i237;
import 'package:heal_app/features/admin/viewmodel/admin_cubit.dart' as _i750;
import 'package:heal_app/features/ai/data/data_source/prediction_api_data_source.dart'
    as _i732;
import 'package:heal_app/features/ai/data/data_source/prediction_remote_data_source.dart'
    as _i383;
import 'package:heal_app/features/ai/data/repository/prediction_repository.dart'
    as _i366;
import 'package:heal_app/features/ai/viewmodel/prediction_cubit.dart' as _i529;
import 'package:heal_app/features/auth/data/data_source/firebase_data_source/firebase_auth_data_source.dart'
    as _i911;
import 'package:heal_app/features/auth/data/data_source/firebase_data_source/firebase_auth_data_source_impl.dart'
    as _i124;
import 'package:heal_app/features/auth/data/repository/auth_repository_impl.dart'
    as _i319;
import 'package:heal_app/features/auth/domain/repository/auth_repository.dart'
    as _i977;
import 'package:heal_app/features/auth/domain/use_case/login_use_case.dart'
    as _i159;
import 'package:heal_app/features/auth/domain/use_case/logout_use_case.dart'
    as _i445;
import 'package:heal_app/features/auth/domain/use_case/register_use_case.dart'
    as _i996;
import 'package:heal_app/features/auth/presentation/cubit/auth_hydrated_cubit.dart'
    as _i823;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.singleton<_i361.Dio>(
      () => registerModule.predictDio,
      instanceName: 'PredictDio',
    );
    gh.singleton<_i361.Dio>(
      () => registerModule.mainDio,
      instanceName: 'MainDio',
    );
    gh.singleton<_i361.Dio>(
      () => registerModule.textPredictDio,
      instanceName: 'TextPredictDio',
    );
    gh.lazySingleton<_i911.FirebaseAuthDataSource>(
      () => _i124.FirebaseAuthDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.singleton<_i361.Dio>(
      () => registerModule.skincancerSurveyDio,
      instanceName: 'SkinCancerSurveyDio',
    );
    gh.singleton<_i361.Dio>(
      () => registerModule.skincancerDio,
      instanceName: 'SkinCancerDio',
    );
    gh.lazySingleton<_i237.AdminDataSource>(
      () => _i237.AdminDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i977.AuthRepository>(
      () => _i319.AuthRepositoryImpl(gh<_i911.FirebaseAuthDataSource>()),
    );
    gh.lazySingleton<_i750.AdminCubit>(
      () => _i750.AdminCubit(gh<_i237.AdminDataSource>()),
    );
    gh.lazySingleton<_i383.PredictionRemoteDataSource>(
      () => _i732.PredictionApiDataSource(
        gh<_i361.Dio>(instanceName: 'MainDio'),
        gh<_i361.Dio>(instanceName: 'PredictDio'),
        gh<_i361.Dio>(instanceName: 'SkinCancerDio'),
        gh<_i361.Dio>(instanceName: 'SkinCancerSurveyDio'),
        gh<_i361.Dio>(instanceName: 'TextPredictDio'),
      ),
    );
    gh.lazySingleton<_i159.LoginUseCase>(
      () => _i159.LoginUseCase(gh<_i977.AuthRepository>()),
    );
    gh.lazySingleton<_i445.LogoutUseCase>(
      () => _i445.LogoutUseCase(gh<_i977.AuthRepository>()),
    );
    gh.lazySingleton<_i996.RegisterUseCase>(
      () => _i996.RegisterUseCase(gh<_i977.AuthRepository>()),
    );
    gh.lazySingleton<_i366.PredictionRepository>(
      () => _i366.PredictionRepository(
        gh<_i383.PredictionRemoteDataSource>(),
        gh<_i911.FirebaseAuthDataSource>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.singleton<_i823.AuthCubit>(
      () => _i823.AuthCubit(
        gh<_i159.LoginUseCase>(),
        gh<_i996.RegisterUseCase>(),
        gh<_i445.LogoutUseCase>(),
      ),
    );
    gh.lazySingleton<_i529.PredictionCubit>(
      () => _i529.PredictionCubit(gh<_i366.PredictionRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i155.RegisterModule {}
