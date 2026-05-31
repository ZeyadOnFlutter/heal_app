import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/app_bloc_observer.dart';
import 'core/service/backend_service.dart';
import 'core/service/notification_service.dart';
import 'core/service/service_locator.dart';
import 'features/admin/view/admin_dashboard.dart';
import 'features/ai/view/analysis_screen.dart';
import 'features/ai/view/doctor_dashboard.dart';
import 'features/ai/view/medical_nav_bar.dart';
import 'features/ai/viewmodel/prediction_cubit.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/cubit/auth_hydrated_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/view/login.dart';
import 'features/chat/chat_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(directory.path),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Register screen builders so NotificationService can navigate
  // without importing screens directly (avoids circular deps).
  NotificationService.instance.registerChatScreenBuilder(({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) =>
      ChatScreen(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      ));

  NotificationService.instance.registerFeedbackScreenBuilder(
    () => const AnalysisScreen(),
  );

  // ── Initialize notifications AFTER Firebase is ready.
  await NotificationService.instance.initialize();

  // ── Initialize backend service.
  BackendService.instance.init();
  await BackendService.instance.isBackendReachable();

  Bloc.observer = AppBlocObserver();
  setupLocator();


  

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<PredictionCubit>(
              create: (context) => getIt<PredictionCubit>()),
          BlocProvider<AuthCubit>(
              create: (context) => getIt<AuthCubit>()),
        ],
        child: const HealAi(),
      ),
    ),
  );
}

class HealAi extends StatelessWidget {
  const HealAi({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          title: 'Medical Detection',
          debugShowCheckedModeBanner: false,
          // ── Attach the navigator key so NotificationService can navigate.
          navigatorKey: NotificationService.navigatorKey,
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          home: BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (previous, current) => current is Authenticated,
            listener: (context, state) {
              if (state is Authenticated) {
                NotificationService.instance
                    .saveFcmToken(role: state.user.role.name);
              }
            },
            builder: (context, state) {
              if (state is Authenticated) {
                return switch (state.user.role) {
                  UserRole.admin => const AdminDashboard(),
                  UserRole.doctor => const DoctorDashboard(),
                  _ => const MedicalNavBar(),
                };
              }
              return const Login();
            },
          ),
        );
      },
    );
  }
}
