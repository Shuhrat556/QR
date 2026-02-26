import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_state.dart';

class GenerateCubit extends Cubit<GenerateState> {
  GenerateCubit() : super(const GenerateState());

  void setType(QrInputType type) {
    emit(state.copyWith(selectedType: type));
  }

  void setClipboardContent(String value) =>
      emit(state.copyWith(clipboardContent: value));

  void setText(String value) => emit(state.copyWith(text: value));

  void setUrl(String value) => emit(state.copyWith(url: value));

  void setPhone(String value) => emit(state.copyWith(phone: value));

  void setEmail(String value) => emit(state.copyWith(email: value));

  void setEmailSubject(String value) =>
      emit(state.copyWith(emailSubject: value));

  void setEmailBody(String value) => emit(state.copyWith(emailBody: value));

  void setWifiSsid(String value) => emit(state.copyWith(wifiSsid: value));

  void setWifiPassword(String value) =>
      emit(state.copyWith(wifiPassword: value));

  void setWifiSecurity(String value) =>
      emit(state.copyWith(wifiSecurity: value));

  void setContactFirstName(String value) =>
      emit(state.copyWith(contactFirstName: value));

  void setContactLastName(String value) =>
      emit(state.copyWith(contactLastName: value));

  void setContactPhone(String value) =>
      emit(state.copyWith(contactPhone: value));

  void setContactEmail(String value) =>
      emit(state.copyWith(contactEmail: value));

  void setContactAddress(String value) =>
      emit(state.copyWith(contactAddress: value));

  void setContactCompany(String value) =>
      emit(state.copyWith(contactCompany: value));

  void setContactJobTitle(String value) =>
      emit(state.copyWith(contactJobTitle: value));

  void setContactWebsite(String value) =>
      emit(state.copyWith(contactWebsite: value));

  void setContactNotes(String value) =>
      emit(state.copyWith(contactNotes: value));

  void setContactBirthDate(String value) =>
      emit(state.copyWith(contactBirthDate: value));

  void setSmsNumber(String value) => emit(state.copyWith(smsNumber: value));

  void setSmsMessage(String value) => emit(state.copyWith(smsMessage: value));

  void setGeoLat(String value) => emit(state.copyWith(geoLat: value));

  void setGeoLng(String value) => emit(state.copyWith(geoLng: value));

  void setGeoQuery(String value) => emit(state.copyWith(geoQuery: value));

  void setCalendarTitle(String value) =>
      emit(state.copyWith(calendarTitle: value));

  void setCalendarStart(String value) =>
      emit(state.copyWith(calendarStart: value));

  void setCalendarEnd(String value) => emit(state.copyWith(calendarEnd: value));

  void setCalendarLocation(String value) =>
      emit(state.copyWith(calendarLocation: value));

  void setCalendarDescription(String value) =>
      emit(state.copyWith(calendarDescription: value));

  void setMyQrVCard(String value) => emit(state.copyWith(myQrVCard: value));

  void setOtherRaw(String value) => emit(state.copyWith(otherRaw: value));
}
