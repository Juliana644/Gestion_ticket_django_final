class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String telephone;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:         json['id'],
      email:      json['email'] ?? '',
      username:   json['username'] ?? '',
      firstName:  json['first_name'] ?? '',
      lastName:   json['last_name'] ?? '',
      role:       json['role'] ?? 'CITOYEN',
      telephone:  json['telephone'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isTechnicien => role == 'TECHNICIEN';
  bool get isAdmin => role == 'ADMIN';
}