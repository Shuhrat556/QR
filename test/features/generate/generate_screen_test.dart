import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/generate/generate_screen.dart';

void main() {
  testWidgets('switches fields by type and enables actions when valid', (tester) async {
    final cubit = GenerateCubit();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GenerateCubit>.value(
          value: cubit,
          child: const Scaffold(body: GenerateScreen()),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('text_field')), findsOneWidget);

    FilledButton saveButton() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save PNG'));

    expect(saveButton().onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey<String>('text_field')), 'Hello QR');
    await tester.pump();

    expect(saveButton().onPressed, isNotNull);

    cubit.setType(QrInputType.url);
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('url_field')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('text_field')), findsNothing);
  });
}
