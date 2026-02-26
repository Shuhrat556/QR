import 'package:flutter/material.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/features/generate/generate_screen.dart';
import 'package:qr_scanner_generator/features/scan/scan_screen.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: <Widget>[
                  Icon(Icons.qr_code_2),
                  SizedBox(width: 8),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: <Tab>[
                  Tab(text: 'Generate', icon: Icon(Icons.qr_code_rounded)),
                  Tab(text: 'Scan', icon: Icon(Icons.qr_code_scanner_rounded)),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: <Widget>[
                  GenerateScreen(),
                  ScanScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
