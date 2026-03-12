class Movie {
  final int id;
  final String title;
  final String? poster;
  final String? overview;
  final double? rating;
  final String? releaseDate;

  Movie({
    required this.id,
    required this.title,
    this.poster,
    this.overview,
    this.rating,
    this.releaseDate,
  });

  // constructeur de la classe Movie
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      poster: json['poster_path'],
      overview: json['overview'],
      rating: json['vote_average']?.toDouble(),
      releaseDate: json['release_date'],
    );
  }

  // convertit un objet Movie en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': poster,
      'overview': overview,
      'vote_average': rating,
      'release_date': releaseDate,
    };
  }
}
