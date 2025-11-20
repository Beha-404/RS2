import 'dart:convert';
import 'dart:typed_data';

class User {
  final int? id;
  final int? role;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? city;
  final String? state;
  final String? country;
  final Uint8List? profilePicture;
  final String? postalCode;
  final String? address;
  final String? username;
  final String? token;

  const User({
    this.id,
    this.username,
    this.role,
    this.token,
    this.email,
    this.firstName,
    this.lastName,
    this.password,
    this.city,
    this.state,
    this.country,
    this.profilePicture,
    this.postalCode,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Uint8List? profilePic;
    final pic = json['profilePicture'];
    if (pic != null && pic is String && pic.isNotEmpty) {
      profilePic = base64Decode(pic);
    }

    return User(
      id: json['id'] as int?,
      username: json['username'] as String?,
      role: json['role'] as int?,
      token: json['token'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      password: json['password'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      profilePicture: profilePic,
      postalCode: json['postalCode'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'role': role,
    'token': token,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'password': password,
    'city': city,
    'state': state,
    'country': country,
    'profilePicture': profilePicture != null
        ? base64Encode(profilePicture!)
        : null,
    'postalCode': postalCode,
    'address': address,
  };

  User copyWith({
    int? id,
    int? role,
    String? password,
    String? email,
    String? firstName,
    String? lastName,
    String? city,
    String? state,
    String? country,
    Uint8List? profilePicture,
    String? postalCode,
    String? address,
    String? username,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      profilePicture: profilePicture ?? this.profilePicture,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
    );
  }
}
