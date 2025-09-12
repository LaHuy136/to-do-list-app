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
}
