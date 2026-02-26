import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';

void main() {
  Widget buildApp(String rawValue) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<QrContentParser>.value(
        value: DefaultQrContentParser(),
        child: ResultScreen(rawValue: rawValue),
      ),
    );
  }

  testWidgets('shows open-link action for URL content', (tester) async {
    await tester.pumpWidget(buildApp('https://example.com'));

    expect(find.text('Open Link'), findsOneWidget);
    expect(find.text('Copy Content'), findsOneWidget);
    expect(find.text('Share Content'), findsOneWidget);
  });

  testWidgets('shows only copy/share for WiFi payload', (tester) async {
    await tester.pumpWidget(buildApp('WIFI:T:WPA;S:OfficeWiFi;P:secret123;;'));

    expect(find.text('Open Link'), findsNothing);
    expect(find.text('Copy Content'), findsOneWidget);
    expect(find.text('Share Content'), findsOneWidget);
  });
}
