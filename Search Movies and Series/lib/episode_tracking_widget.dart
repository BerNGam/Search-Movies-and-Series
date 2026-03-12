import 'package:flutter/material.dart';
import 'db_helper.dart';

// widget de suivi des episodes
class EpisodeTrackingWidget extends StatefulWidget {
  final int seriesId;
  final int seasonNumber;
  final List<dynamic> episodes;

  const EpisodeTrackingWidget({
    required this.seriesId,
    required this.seasonNumber,
    required this.episodes,
  });

  @override
  _EpisodeTrackingWidgetState createState() => _EpisodeTrackingWidgetState();
}

// etat du widget de suivi des episodes
class _EpisodeTrackingWidgetState extends State<EpisodeTrackingWidget> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Map<int, bool> _watchedStatus = {}; //etat de l'episode

  @override
  void initState() {
    super.initState();
    _loadEpisodeStatus(); //chargement de l'etat de l'episode
  }

  //chargement de l'etat de l'episode
  Future<void> _loadEpisodeStatus() async {
    for (var episode in widget.episodes) {
      final watched = await _db.isEpisodeWatched(
        widget.seriesId,
        widget.seasonNumber,
        episode['episode_number'],
      );
      //mise a jour de l'etat de l'episode
      setState(() {
        _watchedStatus[episode['episode_number']] = watched;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.episodes.length,
      itemBuilder: (context, index) {
        final episode = widget.episodes[index];
        final episodeNumber = episode['episode_number'];
        final isWatched = _watchedStatus[episodeNumber] ?? false;

        return ListTile(
          title:
              Text('Episode ${episode['episode_number']}: ${episode['name']}'),
          trailing: Checkbox(
            value: isWatched,
            onChanged: (bool? value) async {
              await _db.markEpisodeAsWatched(
                widget.seriesId,
                widget.seasonNumber,
                episodeNumber,
                value ?? false,
              );
              setState(() {
                _watchedStatus[episodeNumber] = value ?? false;
              });
            },
          ),
        );
      },
    );
  }
}
