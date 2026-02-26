import 'package:equatable/equatable.dart';

class MyQrProfile extends Equatable {
  const MyQrProfile({
    this.firstName = '',
    this.lastName = '',
    this.birthDate = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.company = '',
    this.jobTitle = '',
    this.website = '',
    this.notes = '',
  });

  final String firstName;
  final String lastName;
  final String birthDate;
  final String phone;
  final String email;
  final String address;
  final String company;
  final String jobTitle;
  final String website;
  final String notes;

  bool get isEmpty {
    return firstName.trim().isEmpty &&
        lastName.trim().isEmpty &&
        birthDate.trim().isEmpty &&
        phone.trim().isEmpty &&
        email.trim().isEmpty &&
        address.trim().isEmpty &&
        company.trim().isEmpty &&
        jobTitle.trim().isEmpty &&
        website.trim().isEmpty &&
        notes.trim().isEmpty;
  }

  String toVCard() {
    final lines = <String>['BEGIN:VCARD', 'VERSION:3.0'];

    final fullName = [
      firstName.trim(),
      lastName.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    if (fullName.isNotEmpty) {
      lines.add('FN:${_escape(fullName)}');
      lines.add(
        'N:${_escape(lastName.trim())};${_escape(firstName.trim())};;;',
      );
    }

    if (company.trim().isNotEmpty) {
      lines.add('ORG:${_escape(company.trim())}');
    }
    if (jobTitle.trim().isNotEmpty) {
      lines.add('TITLE:${_escape(jobTitle.trim())}');
    }
    if (phone.trim().isNotEmpty) {
      lines.add('TEL;TYPE=CELL:${_escape(phone.trim())}');
    }
    if (email.trim().isNotEmpty) {
      lines.add('EMAIL:${_escape(email.trim())}');
    }
    if (address.trim().isNotEmpty) {
      lines.add('ADR:;;${_escape(address.trim())};;;;');
    }
    if (website.trim().isNotEmpty) {
      lines.add('URL:${_escape(website.trim())}');
    }
    if (birthDate.trim().isNotEmpty) {
      lines.add('BDAY:${_escape(birthDate.trim())}');
    }
    if (notes.trim().isNotEmpty) {
      lines.add('NOTE:${_escape(notes.trim())}');
    }

    lines.add('END:VCARD');
    return lines.join('\n');
  }

  static String _escape(String input) {
    return input
        .replaceAll(r'\\', r'\\\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\n', r'\n');
  }

  MyQrProfile copyWith({
    String? firstName,
    String? lastName,
    String? birthDate,
    String? phone,
    String? email,
    String? address,
    String? company,
    String? jobTitle,
    String? website,
    String? notes,
  }) {
    return MyQrProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      website: website ?? this.website,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'jobTitle': jobTitle,
      'website': website,
      'notes': notes,
    };
  }

  factory MyQrProfile.fromMap(Map<dynamic, dynamic> map) {
    return MyQrProfile(
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      birthDate: map['birthDate'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      company: map['company'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      website: map['website'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => <Object?>[
    firstName,
    lastName,
    birthDate,
    phone,
    email,
    address,
    company,
    jobTitle,
    website,
    notes,
  ];
}
