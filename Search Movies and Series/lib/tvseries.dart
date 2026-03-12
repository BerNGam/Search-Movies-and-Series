class TvSeries {
  final int id;
  final String title;
  final String? poster;
  final String? overview;
  final double? rating;
  final String? firstAirDate;

  TvSeries({
    required this.id,
    required this.title,
    this.poster,
    this.overview,
    this.rating,
    this.firstAirDate,
  });

  // constructeur de la classe TvSeries
  factory TvSeries.fromJson(Map<String, dynamic> json) {
    return TvSeries(
      id: json['id'],
      title: json['name'] ??
          'Sans titre', //name a la place de title pour les series
      poster: json['poster_path'],
      overview: json['overview'],
      rating: (json['vote_average'] != null)
          ? (json['vote_average'] as num).toDouble()
          : null,
      firstAirDate: json['first_air_date'], //ici aussi
    );
  }

  // convertit un objet TvSeries en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title, // Utilise 'name' pour les series
      'poster_path': poster,
      'overview': overview,
      'vote_average': rating,
      'first_air_date': firstAirDate,
    };
  }
}
