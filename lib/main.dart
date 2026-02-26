import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/qr_image_service.dart';
import 'package:qr_scanner_generator/data/history/hive_history_repository.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/home/cubit/navigation_cubit.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_cubit.dart';
import 'package:qr_scanner_generator/features/splash/splash_screen.dart';

void main() {
  runApp(const QrToolsApp());
}

class QrToolsApp extends StatelessWidget {
  const QrToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<HistoryRepository>(
          create: (_) => HiveHistoryRepository(),
        ),
        RepositoryProvider<QrContentParser>(
          create: (_) => DefaultQrContentParser(),
        ),
        RepositoryProvider<QrImageService>(
          create: (_) => QrImageServiceImpl(),
        ),
        RepositoryProvider<ActionLauncherService>(
          create: (_) => ActionLauncherServiceImpl(),
        ),
        RepositoryProvider<PermissionService>(
          create: (_) => PermissionServiceImpl(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
              BlocProvider<GenerateCubit>(create: (_) => GenerateCubit()),
              BlocProvider<HistoryCubit>(
                create: (context) => HistoryCubit(
                  repository: context.read<HistoryRepository>(),
                ),
              ),
              BlocProvider<ScanCubit>(
                create: (context) => ScanCubit(
                  permissionService: context.read<PermissionService>(),
                ),
              ),
            ],
            child: MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                useMaterial3: true,
              ),
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
