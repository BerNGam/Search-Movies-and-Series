import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'movie.dart';
import 'movie_card.dart';
import 'movie_details_screen.dart';
import 'tvseries.dart';
import 'tvseries_card.dart';
import 'tvseries_details_screen.dart';

// ecran des favoris
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Favoris'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.favoritesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun favori pour le moment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez des films a vos favoris pour les retrouver ici',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favoritesProvider.favoritesList.length,
            itemBuilder: (context, index) {
              final media = favoritesProvider.favoritesList[index];
              if (media is Movie) {
                return MovieListCard(
                  movie: media,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(movie: media),
                      ),
                    );
                  },
                );
              } else if (media is TvSeries) {
                return TvSeriesListCard(
                  serie: media,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TvSeriesDetailsScreen(serie: media),
                      ),
                    );
                  },
                );
              }
              return SizedBox(); // juste projet si le type de media ni screen ni movie
            },
          );
        },
      ),
    );
  }
}
