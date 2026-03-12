import 'package:flutter/material.dart';
import 'movie.dart';

// Carte d'un film
class MovieListCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieListCard({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin:
          EdgeInsets.symmetric(horizontal: 8, vertical: 4), // marge de la carte
      child: InkWell(
        // permet de rendre la carte cliquable
        onTap: onTap,
        child: Row(
          children: [
            if (movie.poster != null)
              ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200${movie.poster}',
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (movie.releaseDate != null) ...[
                      SizedBox(height: 4),
                      Text(
                        _formatDate(movie.releaseDate!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (movie.rating != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(movie.rating!.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                    if (movie.overview != null) ...[
                      SizedBox(height: 4),
                      Text(
                        movie.overview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
