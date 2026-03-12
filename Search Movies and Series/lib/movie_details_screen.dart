import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'film_service.dart';
import 'movie.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'person_details_screen.dart';

// rcran de details d'un film
class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailsScreen({required this.movie});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

// etat de l'ecran de details d'un film
class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final Filmservice filmservice = Filmservice();
  bool _isLoading = true;
  Map<String, dynamic>? _movieDetails;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails(); // charger les details du film
  }

  // charger les details du film
  Future<void> _loadMovieDetails() async {
    try {
      final details = await filmservice.getMFDetails(widget.movie.id);
      setState(() {
        _movieDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
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
                .isFavorite(widget.movie.id),
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
                      await favoritesProvider.toggleFavorite(widget.movie);
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
                  // image et informations de base
                  _buildHeader(),

                  // genres
                  _buildGenres(),

                  // synopsis
                  _buildOverview(),

                  // acteurs principaux
                  _buildCastSection(),

                  // critiques
                  _buildReviewsSection(),

                  // films similaires
                  _buildSimilarMovies(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        if (widget.movie.poster != null)
          Image.network(
            'https://image.tmdb.org/t/p/w500${widget.movie.poster}',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 200),
              Text(
                widget.movie.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              if (widget.movie.rating != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text(
                      ' ${widget.movie.rating!.toStringAsFixed(1)}',
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

  Widget _buildGenres() {
    final genres = _movieDetails?['genres'] as List? ?? [];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Text(widget.movie.overview ?? 'Aucun synopsis disponible'),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    final cast = _movieDetails?['credits']?['cast'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Acteurs principaux',
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
                      actor['profile_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w200${actor['profile_path']}',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null)
                                  return ClipOval(child: child);
                                return SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return CircleAvatar(
                                  radius: 45,
                                  child: Text(actor['name'][0]),
                                );
                              },
                            )
                          : CircleAvatar(
                              radius: 45,
                              child: Text(actor['name'][0]),
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

  Widget _buildReviewsSection() {
    final reviews = _movieDetails?['reviews']?['results'] as List? ?? [];
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
                            child: Text(
                              review['author'],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        review['content'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSimilarMovies() {
    final similarMovies = _movieDetails?['similar']?['results'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Films similaires',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: similarMovies.take(10).length,
            itemBuilder: (context, index) {
              final movie = similarMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(
                        movie: Movie.fromJson(movie),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movie['poster_path'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                            height: 150,
                            width: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 4),
                      Text(
                        movie['title'],
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

  Widget _buildRatingDialog(BuildContext context) {
    double rating = 0;
    final reviewController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Noter ${widget.movie.title}'),
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
                      constraints: BoxConstraints.tightFor(),
                      padding: EdgeInsets.zero,
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
                  widget.movie.id,
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
