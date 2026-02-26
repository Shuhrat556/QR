import 'package:equatable/equatable.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/utils/qr_payload_builder.dart';

class GenerateState extends Equatable {
  const GenerateState({
    this.selectedType = QrInputType.text,
    this.text = '',
    this.url = '',
    this.phone = '',
    this.email = '',
    this.emailSubject = '',
    this.emailBody = '',
    this.wifiSsid = '',
    this.wifiPassword = '',
    this.wifiSecurity = 'WPA',
  });

  final QrInputType selectedType;
  final String text;
  final String url;
  final String phone;
  final String email;
  final String emailSubject;
  final String emailBody;
  final String wifiSsid;
  final String wifiPassword;
  final String wifiSecurity;

  String? get qrPayload => QrPayloadBuilder.buildPayload(
    type: selectedType,
    text: text,
    url: url,
    phone: phone,
    email: email,
    emailSubject: emailSubject,
    emailBody: emailBody,
    wifiSsid: wifiSsid,
    wifiPassword: wifiPassword,
    wifiSecurity: wifiSecurity,
  );

  bool get isValid => qrPayload != null;

  GenerateState copyWith({
    QrInputType? selectedType,
    String? text,
    String? url,
    String? phone,
    String? email,
    String? emailSubject,
    String? emailBody,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiSecurity,
  }) {
    return GenerateState(
      selectedType: selectedType ?? this.selectedType,
      text: text ?? this.text,
      url: url ?? this.url,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiSecurity: wifiSecurity ?? this.wifiSecurity,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    selectedType,
    text,
    url,
    phone,
    email,
    emailSubject,
    emailBody,
    wifiSsid,
    wifiPassword,
    wifiSecurity,
  ];
}
