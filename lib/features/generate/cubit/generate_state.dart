import 'package:equatable/equatable.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/utils/qr_payload_builder.dart';

class GenerateState extends Equatable {
  const GenerateState({
    this.selectedType = QrInputType.text,
    this.clipboardContent = '',
    this.text = '',
    this.url = '',
    this.phone = '',
    this.email = '',
    this.emailSubject = '',
    this.emailBody = '',
    this.wifiSsid = '',
    this.wifiPassword = '',
    this.wifiSecurity = 'WPA',
    this.contactFirstName = '',
    this.contactLastName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.contactAddress = '',
    this.contactCompany = '',
    this.contactJobTitle = '',
    this.contactWebsite = '',
    this.contactNotes = '',
    this.contactBirthDate = '',
    this.smsNumber = '',
    this.smsMessage = '',
    this.geoLat = '',
    this.geoLng = '',
    this.geoQuery = '',
    this.calendarTitle = '',
    this.calendarStart = '',
    this.calendarEnd = '',
    this.calendarLocation = '',
    this.calendarDescription = '',
    this.myQrVCard = '',
    this.otherRaw = '',
  });

  final QrInputType selectedType;
  final String clipboardContent;
  final String text;
  final String url;
  final String phone;
  final String email;
  final String emailSubject;
  final String emailBody;
  final String wifiSsid;
  final String wifiPassword;
  final String wifiSecurity;
  final String contactFirstName;
  final String contactLastName;
  final String contactPhone;
  final String contactEmail;
  final String contactAddress;
  final String contactCompany;
  final String contactJobTitle;
  final String contactWebsite;
  final String contactNotes;
  final String contactBirthDate;
  final String smsNumber;
  final String smsMessage;
  final String geoLat;
  final String geoLng;
  final String geoQuery;
  final String calendarTitle;
  final String calendarStart;
  final String calendarEnd;
  final String calendarLocation;
  final String calendarDescription;
  final String myQrVCard;
  final String otherRaw;

  String? get qrPayload => QrPayloadBuilder.buildPayload(
    type: selectedType,
    clipboardContent: clipboardContent,
    text: text,
    url: url,
    phone: phone,
    email: email,
    emailSubject: emailSubject,
    emailBody: emailBody,
    wifiSsid: wifiSsid,
    wifiPassword: wifiPassword,
    wifiSecurity: wifiSecurity,
    contactFirstName: contactFirstName,
    contactLastName: contactLastName,
    contactPhone: contactPhone,
    contactEmail: contactEmail,
    contactAddress: contactAddress,
    contactCompany: contactCompany,
    contactJobTitle: contactJobTitle,
    contactWebsite: contactWebsite,
    contactNotes: contactNotes,
    contactBirthDate: contactBirthDate,
    smsNumber: smsNumber,
    smsMessage: smsMessage,
    geoLat: geoLat,
    geoLng: geoLng,
    geoQuery: geoQuery,
    calendarTitle: calendarTitle,
    calendarStart: calendarStart,
    calendarEnd: calendarEnd,
    calendarLocation: calendarLocation,
    calendarDescription: calendarDescription,
    myQrVCard: myQrVCard,
    otherRaw: otherRaw,
  );

  bool get isValid => qrPayload != null;

  GenerateState copyWith({
    QrInputType? selectedType,
    String? clipboardContent,
    String? text,
    String? url,
    String? phone,
    String? email,
    String? emailSubject,
    String? emailBody,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiSecurity,
    String? contactFirstName,
    String? contactLastName,
    String? contactPhone,
    String? contactEmail,
    String? contactAddress,
    String? contactCompany,
    String? contactJobTitle,
    String? contactWebsite,
    String? contactNotes,
    String? contactBirthDate,
    String? smsNumber,
    String? smsMessage,
    String? geoLat,
    String? geoLng,
    String? geoQuery,
    String? calendarTitle,
    String? calendarStart,
    String? calendarEnd,
    String? calendarLocation,
    String? calendarDescription,
    String? myQrVCard,
    String? otherRaw,
  }) {
    return GenerateState(
      selectedType: selectedType ?? this.selectedType,
      clipboardContent: clipboardContent ?? this.clipboardContent,
      text: text ?? this.text,
      url: url ?? this.url,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiSecurity: wifiSecurity ?? this.wifiSecurity,
      contactFirstName: contactFirstName ?? this.contactFirstName,
      contactLastName: contactLastName ?? this.contactLastName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      contactAddress: contactAddress ?? this.contactAddress,
      contactCompany: contactCompany ?? this.contactCompany,
      contactJobTitle: contactJobTitle ?? this.contactJobTitle,
      contactWebsite: contactWebsite ?? this.contactWebsite,
      contactNotes: contactNotes ?? this.contactNotes,
      contactBirthDate: contactBirthDate ?? this.contactBirthDate,
      smsNumber: smsNumber ?? this.smsNumber,
      smsMessage: smsMessage ?? this.smsMessage,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      geoQuery: geoQuery ?? this.geoQuery,
      calendarTitle: calendarTitle ?? this.calendarTitle,
      calendarStart: calendarStart ?? this.calendarStart,
      calendarEnd: calendarEnd ?? this.calendarEnd,
      calendarLocation: calendarLocation ?? this.calendarLocation,
      calendarDescription: calendarDescription ?? this.calendarDescription,
      myQrVCard: myQrVCard ?? this.myQrVCard,
      otherRaw: otherRaw ?? this.otherRaw,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    selectedType,
    clipboardContent,
    text,
    url,
    phone,
    email,
    emailSubject,
    emailBody,
    wifiSsid,
    wifiPassword,
    wifiSecurity,
    contactFirstName,
    contactLastName,
    contactPhone,
    contactEmail,
    contactAddress,
    contactCompany,
    contactJobTitle,
    contactWebsite,
    contactNotes,
    contactBirthDate,
    smsNumber,
    smsMessage,
    geoLat,
    geoLng,
    geoQuery,
    calendarTitle,
    calendarStart,
    calendarEnd,
    calendarLocation,
    calendarDescription,
    myQrVCard,
    otherRaw,
  ];
}
