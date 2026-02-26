import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/my_qr_profile.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/generate/generate_screen.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';

class _FakeMyQrProfileRepository implements MyQrProfileRepository {
  MyQrProfile _profile = const MyQrProfile();

  @override
  Future<void> init() async {}

  @override
  Future<MyQrProfile> read() async => _profile;

  @override
  Future<void> save(MyQrProfile profile) async {
    _profile = profile;
  }
}

void main() {
  testWidgets('switches fields by type and enables actions when valid', (
    tester,
  ) async {
    final cubit = GenerateCubit();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepositoryProvider<MyQrProfileRepository>(
          create: (_) => _FakeMyQrProfileRepository(),
          child: BlocProvider<GenerateCubit>.value(
            value: cubit,
            child: const Scaffold(body: GenerateScreen()),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('text_field')), findsOneWidget);

    FilledButton saveButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save PNG'),
    );

    expect(saveButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('text_field')),
      'Hello QR',
    );
    await tester.pump();

    expect(saveButton().onPressed, isNotNull);

    cubit.setType(QrInputType.url);
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('url_field')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('text_field')), findsNothing);
  });
}
