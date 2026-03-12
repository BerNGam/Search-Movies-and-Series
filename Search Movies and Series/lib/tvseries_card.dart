// tv_show_card.dart
import 'package:flutter/material.dart';
import 'tvseries.dart';
import 'film_service.dart';

// carte d'une serie
class TvSeriesListCard extends StatelessWidget {
  final TvSeries serie;
  final VoidCallback onTap; // fonction a executer lors du clic

  const TvSeriesListCard({
    required this.serie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (serie.poster != null)
              ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200${serie.poster}',
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.error),
                    );
                  },
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serie.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (serie.firstAirDate != null) ...[
                      SizedBox(height: 4),
                      Text(
                        _formatDate(serie.firstAirDate!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (serie.rating != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(serie.rating!.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                    if (serie.overview != null) ...[
                      SizedBox(height: 4),
                      Text(
                        serie.overview!,
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
