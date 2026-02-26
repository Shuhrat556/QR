import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/models/my_qr_profile.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';

class HiveMyQrProfileRepository implements MyQrProfileRepository {
  HiveMyQrProfileRepository({
    Future<void> Function()? initializer,
    Future<Box<dynamic>> Function(String boxName)? boxOpener,
  }) : _initializer = initializer ?? Hive.initFlutter,
       _boxOpener = boxOpener ?? ((boxName) => Hive.openBox<dynamic>(boxName));

  final Future<void> Function() _initializer;
  final Future<Box<dynamic>> Function(String boxName) _boxOpener;
  Box<dynamic>? _box;

  static const String _profileKey = 'profile';

  @override
  Future<void> init() async {
    await _initializer();
    _box ??= await _boxOpener(AppConstants.myQrProfileBoxName);
  }

  Box<dynamic> get _profileBox {
    final box = _box;
    if (box == null) {
      throw StateError('My QR repository is not initialized.');
    }
    return box;
  }

  @override
  Future<MyQrProfile> read() async {
    final value = _profileBox.get(_profileKey);
    if (value is! Map) {
      return const MyQrProfile();
    }
    return MyQrProfile.fromMap(value);
  }

  @override
  Future<void> save(MyQrProfile profile) async {
    await _profileBox.put(_profileKey, profile.toMap());
  }
}
