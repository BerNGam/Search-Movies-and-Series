class Person {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthdate;
  final String? placeOfBirth;
  final List<dynamic>? knownFor;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthdate,
    this.placeOfBirth,
    this.knownFor,
  });

  // Constructeur de la classe Person
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      biography: json['biography'],
      birthdate: json['birthday'],
      placeOfBirth: json['place_of_birth'],
      knownFor: json['known_for'],
    );
  }
}
