import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'film_service.dart';
import 'movie.dart';
import 'tvseries.dart';
import 'movie_card.dart';
import 'tvseries_card.dart';
import 'movie_details_screen.dart';
import 'tvseries_details_screen.dart';
import 'db_helper.dart';

// Ecran d'accueil
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Etat de l'ecran d'accueil
class _HomeScreenState extends State<HomeScreen> {
  final Filmservice _filmService = Filmservice();

  final DatabaseHelper _db = DatabaseHelper.instance;
  //List<Movie> _recommendations = [];

  bool _isLoading = true;

  List<Movie> _popularMovies = [];
  List<TvSeries> _popularSeries = [];

  List<Movie> _recommendedMovies = [];
  List<TvSeries> _recommendedSeries = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  // Charger le contenu
  Future<void> _loadContent() async {
    try {
      // Charger le contenu populaire
      final popularMovies = await _filmService.getPopularMovies();
      final popularSeries = await _filmService.getPopularTvSeries();

      // Charger les favoris depuis la base de données
      final favorites = await _db.getFavorites();

      List<Movie> recommendedMovies = [];
      List<TvSeries> recommendedSeries = [];

      if (favorites.isNotEmpty) {
        for (var favorite in favorites.take(3)) {
          if (favorite is Movie) {
            final movieRecs =
                await _filmService.getMovieRecommendations(favorite.id);
            recommendedMovies.addAll(movieRecs);
          } else if (favorite is TvSeries) {
            final seriesRecs =
                await _filmService.getTvSeriesRecommendations(favorite.id);
            recommendedSeries.addAll(seriesRecs);
          }
        }
        recommendedMovies = recommendedMovies.take(10).toList();
        recommendedSeries = recommendedSeries.take(10).toList();
      }
      setState(() {
        _popularMovies = popularMovies;
        _popularSeries = popularSeries;
        _recommendedMovies = recommendedMovies;
        _recommendedSeries = recommendedSeries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // verifier si le widget est toujours monte avant d'afficher le SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du contenu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContent,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Films Populaires',
                        _popularMovies,
                        (movie) => _buildMovieCard(movie as Movie),
                      ),
                      _buildSection(
                        'Séries Populaires',
                        _popularSeries,
                        (series) => _buildSeriesCard(series as TvSeries),
                      ),
                      if (_recommendedMovies.isNotEmpty)
                        _buildSection(
                          'Films Recommandés',
                          _recommendedMovies,
                          (movie) => _buildMovieCard(movie as Movie),
                        ),
                      if (_recommendedSeries.isNotEmpty)
                        _buildSection(
                          'Séries Recommandées',
                          _recommendedSeries,
                          (series) => _buildSeriesCard(series as TvSeries),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // une carte de film
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie)),
      ),
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.poster}',
                height: 240,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    width: 160,
                    color: Colors.grey[300],
                    child: Icon(Icons.movie, size: 50),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (movie.rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    movie.rating!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // une carte de serie
  Widget _buildSeriesCard(TvSeries series) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvSeriesDetailsScreen(serie: series),
        ),
      ),
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${series.poster}',
                height: 240,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    width: 160,
                    color: Colors.grey[300],
                    child: Icon(Icons.tv, size: 50),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              series.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (series.rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    series.rating!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    Widget Function(dynamic) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(items[index]),
          ),
        ),
      ],
    );
  }
}
