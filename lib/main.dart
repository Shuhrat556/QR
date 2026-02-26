import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/app_preferences_repository.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/qr_image_service.dart';
import 'package:qr_scanner_generator/core/services/scan_image_service.dart';
import 'package:qr_scanner_generator/data/history/hive_history_repository.dart';
import 'package:qr_scanner_generator/data/my_qr/hive_my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/data/preferences/hive_app_preferences_repository.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/home/cubit/navigation_cubit.dart';
import 'package:qr_scanner_generator/features/preferences/cubit/app_preferences_cubit.dart';
import 'package:qr_scanner_generator/features/preferences/cubit/app_preferences_state.dart';
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
        RepositoryProvider<AppPreferencesRepository>(
          create: (_) => HiveAppPreferencesRepository(),
        ),
        RepositoryProvider<MyQrProfileRepository>(
          create: (_) => HiveMyQrProfileRepository(),
        ),
        RepositoryProvider<QrContentParser>(
          create: (_) => DefaultQrContentParser(),
        ),
        RepositoryProvider<QrImageService>(create: (_) => QrImageServiceImpl()),
        RepositoryProvider<ActionLauncherService>(
          create: (_) => ActionLauncherServiceImpl(),
        ),
        RepositoryProvider<PermissionService>(
          create: (_) => PermissionServiceImpl(),
        ),
        RepositoryProvider<ScanImageService>(
          create: (_) => ScanImageServiceImpl(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
              BlocProvider<GenerateCubit>(create: (_) => GenerateCubit()),
              BlocProvider<HistoryCubit>(
                create: (context) =>
                    HistoryCubit(repository: context.read<HistoryRepository>()),
              ),
              BlocProvider<ScanCubit>(
                create: (context) => ScanCubit(
                  permissionService: context.read<PermissionService>(),
                ),
              ),
              BlocProvider<AppPreferencesCubit>(
                create: (context) => AppPreferencesCubit(
                  repository: context.read<AppPreferencesRepository>(),
                )..load(),
              ),
            ],
            child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
              builder: (context, prefState) {
                final locale = prefState.locale;
                final themeMode = prefState.themeMode;
                return MaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.teal,
                      brightness: Brightness.dark,
                    ),
                    useMaterial3: true,
                  ),
                  home: const SplashScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
