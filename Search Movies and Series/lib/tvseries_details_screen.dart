import 'package:flutter/material.dart';
import 'package:projetmovie/movie.dart';
import 'package:projetmovie/person_details_screen.dart';
import 'package:provider/provider.dart';
import 'film_service.dart';
import 'tvseries.dart';
import 'favorites_provider.dart';
import 'db_helper.dart';
import 'episode_tracking_widget.dart';

// ecran de details d'une serie
class TvSeriesDetailsScreen extends StatefulWidget {
  final TvSeries serie;

  TvSeriesDetailsScreen({required this.serie});

  @override
  _TvSeriesDetailsScreenState createState() => _TvSeriesDetailsScreenState();
}

// etat de l'ecran de details d'une serie
class _TvSeriesDetailsScreenState extends State<TvSeriesDetailsScreen> {
  final Filmservice filmservice = Filmservice();
  bool _isLoading = true;
  Map<String, dynamic>? _serieDetails; // details de la serie

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadSerieDetails(); // charge les details de la serie
  }

  // charge les details de la serie
  Future<void> _loadSerieDetails() async {
    try {
      final details =
          await filmservice.getMFDetails(widget.serie.id, isMovie: false);
      setState(() {
        _serieDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des détails')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serie.title),
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildRatingDialog(context),
              );
            },
          ),
          FutureBuilder<bool>(
            future: Provider.of<FavoritesProvider>(context, listen: false)
                .isFavorite(widget.serie.id),
            builder: (context, snapshot) {
              return Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () async {
                      await favoritesProvider.toggleFavorite(widget.serie);
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // affiche l'en tete
                  _buildHeader(),
                  // affiche les genres
                  _buildGenres(),
                  // affiche le synopsis
                  _buildOverview(),
                  // affiche les saisons
                  _buildSeasonsList(),
                  // affiche la distribution
                  _buildCastSection(),
                  // affiche les critiques
                  _buildReviewsSection(),
                  // affiche les series similaires
                  _buildSimilarSeries(),
                ],
              ),
            ),
    );
  }

  // header
  Widget _buildHeader() {
    return Stack(
      children: [
        if (widget.serie.poster != null)
          Image.network(
            'https://image.tmdb.org/t/p/w500${widget.serie.poster}',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        Container(
          height: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.serie.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              if (widget.serie.rating != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text(
                      ' ${widget.serie.rating!.toStringAsFixed(1)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // genres
  Widget _buildGenres() {
    final genres = _serieDetails?['genres'] as List? ?? [];
    return Padding(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: genres.map<Widget>((genre) {
          return Chip(
            label: Text(genre['name']),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          );
        }).toList(),
      ),
    );
  }

  // synopsis
  Widget _buildOverview() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(widget.serie.overview ?? 'Aucun synopsis disponible'),
        ],
      ),
    );
  }

  // liste des saisons
  Widget _buildSeasonsList() {
    final seasons = _serieDetails?['seasons'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Saisons', style: Theme.of(context).textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return ExpansionTile(
              leading: season['poster_path'] != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w200${season['poster_path']}',
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.tv),
              title: Text('Saison ${season['season_number']}'),
              subtitle: Text('${season['episode_count']} épisodes'),
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: filmservice.getSeasonDetails(
                    widget.serie.id,
                    season['season_number'],
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();

                    return EpisodeTrackingWidget(
                      seriesId: widget.serie.id,
                      seasonNumber: season['season_number'],
                      episodes: snapshot.data!['episodes'] as List,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // section de distribution
  Widget _buildCastSection() {
    final cast = _serieDetails?['credits']?['cast'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.take(10).length,
            itemBuilder: (context, index) {
              final actor = cast[index];
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonDetailsScreen(
                          personId: actor['id'],
                          name: actor['name'],
                          profilePath: actor['profile_path'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: actor['profile_path'] != null
                            ? NetworkImage(
                                'https://image.tmdb.org/t/p/w200${actor['profile_path']}')
                            : null,
                        child: actor['profile_path'] == null
                            ? Text(actor['name'][0])
                            : null,
                      ),
                      SizedBox(height: 8),
                      Text(
                        actor['name'],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        actor['character'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // series similaires //verifier bien
  Widget _buildSimilarSeries() {
    final similarSeries = _serieDetails?['similar']?['results'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Séries similaires',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: similarSeries.length,
            itemBuilder: (context, index) {
              final series = similarSeries[index];
              if (series == null || series is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }

              final name = series['name'] as String? ?? 'Titre inconnu';
              final posterPath = series['poster_path'] as String?;

              return GestureDetector(
                onTap: () {
                  if (series.containsKey('id')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TvSeriesDetailsScreen(
                          serie: TvSeries.fromJson(series),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (posterPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200$posterPath',
                            height: 150,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.tv),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          width: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.tv),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // review section
  Widget _buildReviewsSection() {
    final reviews = _serieDetails?['reviews']?['results'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Critiques',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (reviews.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aucune critique disponible'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.take(3).length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(review['author'][0].toUpperCase()),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['author'],
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                if (review['created_at'] != null)
                                  Text(
                                    _formatDate(review['created_at']),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        review['content'],
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(review['author']),
                              content: SingleChildScrollView(
                                child: Text(review['content']),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Lire la suite'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // boite de dialogue de notation
  Widget _buildRatingDialog(BuildContext context) {
    double rating = 0;
    final reviewController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Noter ${widget.serie.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Flexible(
                    // Ajouter Flexible ici
                    fit: FlexFit.loose,
                    child: IconButton(
                      constraints:
                          BoxConstraints.tightFor(), // Réduire les contraintes
                      padding: EdgeInsets.zero, // Réduire le padding
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  labelText: 'Votre avis',
                  hintText: 'Ecrivez votre critique...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.updateUserRating(
                  widget.serie.id,
                  rating,
                  reviewController.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note enregistree !'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
