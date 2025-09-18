class User {
  final int id;
  final String username;
  final String email;
  final String? profession;
  final String? dateOfBirth;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profession,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profession: json['profession'],
      dateOfBirth: json['dateofbirth'],
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? profession,
    String? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profession: profession ?? this.profession,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
