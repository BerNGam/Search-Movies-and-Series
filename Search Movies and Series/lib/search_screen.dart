import 'package:flutter/material.dart';
import 'film_service.dart';
import 'movie.dart';
import 'movie_details_screen.dart';
import 'movie_card.dart';
import 'tvseries_card.dart';
import 'tvseries.dart';
import 'tvseries_details_screen.dart';

// ecran de recherche
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// etat de l'ecran de recherche
class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final Filmservice filmservice = Filmservice();
  List<Movie> _movies = [];
  List<TvSeries> _TvSeries = [];
  bool _isLoading = false;
  late TabController _tabController; // controleur des onglets

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // dispose du controleur des onglets
    _tabController.dispose();
    super.dispose();
  }

  // recherche
  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _movies = [];
        _TvSeries = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // rechercher les films et series
      final results = await filmservice.searchAll(query);
      setState(() {
        _movies = results['movies'];
        _TvSeries = results['series'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la recherche')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechercher'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Films'),
            Tab(text: 'Series'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un film ou une serie',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMoviesList(),
                      _buildTvSeriesList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // affiche la liste des films
  Widget _buildMoviesList() {
    if (_movies.isEmpty) {
      return Center(
        child: Text('Aucun film trouve'),
      );
    }

    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return MovieListCard(
          movie: _movies[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(movie: _movies[index]),
              ),
            );
          },
        );
      },
    );
  }

  // affiche la liste des series
  Widget _buildTvSeriesList() {
    if (_TvSeries.isEmpty) {
      return Center(
        child: Text('Aucune serie trouvee'),
      );
    }

    return ListView.builder(
      itemCount: _TvSeries.length,
      itemBuilder: (context, index) {
        final show = _TvSeries[index];
        return TvSeriesListCard(
          serie: show,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TvSeriesDetailsScreen(serie: show),
              ),
            );
          },
        );
      },
    );
  }
}
