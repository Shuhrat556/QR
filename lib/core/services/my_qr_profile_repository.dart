import 'package:qr_scanner_generator/core/models/my_qr_profile.dart';

abstract class MyQrProfileRepository {
  Future<void> init();

  Future<MyQrProfile> read();

  Future<void> save(MyQrProfile profile);
}
