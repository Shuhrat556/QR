import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/models/parsed_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class ActionLauncherService {
  Future<void> launchPrimaryAction(ParsedResult result);

  Future<void> openPrivacyPolicy();

  Future<void> openOurApps();

  Future<void> shareApp({required String text});
}

class ActionLauncherServiceImpl implements ActionLauncherService {
  @override
  Future<void> launchPrimaryAction(ParsedResult result) async {
    final uri = result.primaryActionUri;
    if (uri == null) {
      throw StateError('No action URI available for this content type.');
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError('Unable to launch URI: $uri');
    }
  }

  @override
  Future<void> openPrivacyPolicy() {
    return _launchExternal(Uri.parse(AppConstants.privacyPolicyUrl));
  }

  @override
  Future<void> openOurApps() {
    return _launchExternal(Uri.parse(AppConstants.ourAppsUrl));
  }

  @override
  Future<void> shareApp({required String text}) {
    return SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _launchExternal(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError('Unable to launch URI: $uri');
    }
  }
}
