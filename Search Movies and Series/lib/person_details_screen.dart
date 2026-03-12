import 'package:flutter/material.dart';
import 'film_service.dart';
import 'movie_details_screen.dart';
import 'tvseries_details_screen.dart';
import 'movie.dart';
import 'tvseries.dart';
import 'person.dart';

// ecran de details d'une personne
class PersonDetailsScreen extends StatefulWidget {
  final int personId;
  final String name;
  final String? profilePath;

  PersonDetailsScreen({
    required this.personId,
    required this.name,
    this.profilePath,
  });

  @override
  _PersonDetailsScreenState createState() => _PersonDetailsScreenState();
}

// etat de lecran de details d'une personne
class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  final Filmservice _filmService = Filmservice();
  bool _isLoading = true;
  Person? _personDetails;
  List<dynamic> _credits = [];
  Set<int> _uniqueCredits = Set<int>(); // pour eviter les doublons

  @override
  void initState() {
    super.initState();
    _loadPersonDetails(); // charge les details de la personne
  }

  // charge les details de la personne
  Future<void> _loadPersonDetails() async {
    try {
      final response = await _filmService.getPersonDetails(widget.personId);
      final credits = await _filmService.getPersonCredits(widget.personId);

      setState(() {
        _personDetails = Person.fromJson(response);
        _credits = credits
            .where((credit) => _uniqueCredits.add(credit['id']))
            .toList();
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // affiche la biographie
                      _buildBiography(),
                      // affiche les informations personnelles
                      _buildPersonalInfo(),
                      // affiche la filmographie
                      _buildFilmography(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.name, style: TextStyle(color: Colors.amber)),
        background: widget.profilePath != null
            ? Image.network(
                'https://image.tmdb.org/t/p/w500${widget.profilePath}',
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey,
                child: Icon(Icons.person, size: 100),
              ),
      ),
    );
  }

  Widget _buildBiography() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biographie',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          Text(
            _personDetails?.biography?.isNotEmpty == true
                ? _personDetails!.biography!
                : 'Aucune biographie disponible pour cet artiste.',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          if (_personDetails?.birthdate != null)
            ListTile(
              leading: Icon(Icons.cake),
              title: Text('Date de naissance'),
              subtitle: Text(_formatDate(_personDetails!.birthdate!)),
            ),
          if (_personDetails?.placeOfBirth != null)
            ListTile(
              // Affiche un ListTile
              leading: Icon(Icons.location_on),
              title: Text('Lieu de naissance'),
              subtitle: Text(_personDetails!.placeOfBirth!),
            ),
        ],
      ),
    );
  }

  Widget _buildFilmography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Filmographie',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _credits.length,
          itemBuilder: (context, index) {
            final credit = _credits[index];
            final isMovie = credit['media_type'] == 'movie';

            return ListTile(
              leading: credit['poster_path'] != null
                  ? Stack(
                      children: [
                        Image.network(
                          'https://image.tmdb.org/t/p/w200${credit['poster_path']}',
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ],
                    )
                  : Icon(isMovie ? Icons.movie : Icons.tv),
              title: Text(isMovie ? credit['title'] : credit['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isMovie
                        ? MovieDetailsScreen(movie: Movie.fromJson(credit))
                        : TvSeriesDetailsScreen(
                            serie: TvSeries.fromJson(credit)),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // jj/mm/aaaa
  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
