import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';

class NavigationCubit extends Cubit<AppSection> {
  NavigationCubit() : super(AppSection.scan);

  void setSection(AppSection section) {
    if (section == state) {
      return;
    }
    emit(section);
  }
}
