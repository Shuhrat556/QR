import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_state.dart';

class GenerateCubit extends Cubit<GenerateState> {
  GenerateCubit() : super(const GenerateState());

  void setType(QrInputType type) {
    emit(state.copyWith(selectedType: type));
  }

  void setText(String value) {
    emit(state.copyWith(text: value));
  }

  void setUrl(String value) {
    emit(state.copyWith(url: value));
  }

  void setPhone(String value) {
    emit(state.copyWith(phone: value));
  }

  void setEmail(String value) {
    emit(state.copyWith(email: value));
  }

  void setEmailSubject(String value) {
    emit(state.copyWith(emailSubject: value));
  }

  void setEmailBody(String value) {
    emit(state.copyWith(emailBody: value));
  }

  void setWifiSsid(String value) {
    emit(state.copyWith(wifiSsid: value));
  }

  void setWifiPassword(String value) {
    emit(state.copyWith(wifiPassword: value));
  }

  void setWifiSecurity(String value) {
    emit(state.copyWith(wifiSecurity: value));
  }
}
