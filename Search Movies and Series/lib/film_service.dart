import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'tvseries.dart';

// Service pour charger les films et series
class Filmservice {
  final String apiKey = '03d8c497fea1a8f8bba7d547e70134dd';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Charge les details d'un film
  Future<List<Movie>> searchMovies(String query) async {
    final response = await http
        .get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Erreur lors du chargement des films');
    }
  }

  //charge details movies series
  Future<Map<String, dynamic>> getMFDetails(int id,
      {bool isMovie = true}) async {
    final endpointType = isMovie ? 'movie' : 'tv';
    final response = await http.get(Uri.parse(
        '$baseUrl/$endpointType/$id?api_key=$apiKey&append_to_response=credits,similar,reviews,seasons'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des details MF');
    }
  }

  //pour recuperer les details dune saison
  Future<Map<String, dynamic>> getSeasonDetails(
      int seriesId, int seasonNumber) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/tv/$seriesId/season/$seasonNumber?api_key=$apiKey&language=fr-FR'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors du chargement des details de la saison');
    }
  }

  //pour rechercher les series
  Future<List<TvSeries>> searchTvSeries(String query) async {
    final response = await http
        .get(Uri.parse('$baseUrl/search/tv?api_key=$apiKey&query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((show) => TvSeries.fromJson(show)).toList();
    } else {
      throw Exception('Erreur lors du chargement des series');
    }
  }

  //pour rechercher les films et series
  Future<Map<String, dynamic>> searchAll(String query) async {
    final movies = await searchMovies(query);
    final series = await searchTvSeries(query);
    return {
      'movies': movies,
      'series': series,
    };
  }

  //pour recuperer les recommandations de films
  Future<List<Movie>> getMovieRecommendations(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/recommendations?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Erreur lors du chargement des recommandations de films');
    }
  }

  //pour recuperer les recommandations de series
  Future<List<TvSeries>> getTvSeriesRecommendations(int showId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$showId/recommendations?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((show) => TvSeries.fromJson(show)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des recommandations de series');
    }
  }

  //pour recuperer les films populaires
  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Erreur lors du chargement des films populaires');
    }
  }

  //pour recuperer les series populaires
  Future<List<TvSeries>> getPopularTvSeries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/popular?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((show) => TvSeries.fromJson(show)).toList();
    } else {
      throw Exception('Erreur lors du chargement des series populaires');
    }
  }

  //pour recuperer les details dune personne
  Future<Map<String, dynamic>> getPersonDetails(int personId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/person/$personId?api_key=$apiKey&language=fr-FR'), //en francais
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des details de la personne');
    }
  }

  //pour recuperer les credits dune personne
  Future<List<dynamic>> getPersonCredits(int personId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/person/$personId/combined_credits?api_key=$apiKey&language=fr-FR'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> cast = data['cast'] ?? [];
      final List<dynamic> crew = data['crew'] ?? [];

      // Combine et trie par date de sortie
      final allCredits = [...cast, ...crew];
      allCredits.sort((a, b) {
        final aDate = a['release_date'] ?? a['first_air_date'] ?? '';
        final bDate = b['release_date'] ?? b['first_air_date'] ?? '';
        return bDate.compareTo(aDate);
      });

      return allCredits;
    } else {
      throw Exception('Erreur lors du chargement des credits de la personne');
    }
  }
}
