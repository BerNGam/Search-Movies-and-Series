import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';
import 'tvseries.dart';

class DatabaseHelper {
  //initialisation de la db
  static final DatabaseHelper instance =
      DatabaseHelper._init(); //unique instance
  static Database? _database; //instance de la db

  DatabaseHelper._init(); //constructeur prive

  //retourne l'instance de la db
  Future<Database> get database async {
    if (_database != null) return _database!; //si la db existe on la retourne
    _database = await _initDB('favorites.db'); //sinon on l'initialise
    return _database!;
  }

  //initialisation de la db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, //creation des tables
    );
  }

  //creation des tables de la db
  Future<void> _createDB(Database db, int version) async {
    // table des favoris
    //id: identifiant unique
    //type: type du media (film ou serie)
    //title: titre du media
    //poster: affiche du media
    //overview: description du media
    //rating: note du media
    //releaseDate: date de sortie du media
    //data: données du media en format JSON
    //userRating: note personnelle du media
    //userReview: critique personnelle du media
    await db.execute('''
    CREATE TABLE favorites ( 
      id INTEGER PRIMARY KEY,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      poster TEXT,
      overview TEXT,
      rating REAL,
      releaseDate TEXT,
      data TEXT NOT NULL, 
      userRating REAL,
      userReview TEXT
    )
  ''');

    // table de suivi des episodes
    //id: identifiant unique
    //series_id: identifiant de la serie
    //season_number: numero de la saison
    //episode_number: numero de l'episode
    //episode_title: titre de l'episode
    //watched: indique si l'episode a été vu
    await db.execute('''
      CREATE TABLE episode_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        series_id INTEGER,
        season_number INTEGER,
        episode_number INTEGER,
        episode_title TEXT,
        watched BOOLEAN DEFAULT 0,
        UNIQUE(series_id, season_number, episode_number)
      )
    ''');
  }

  //ajoute un media aux favoris
  Future<void> addFavorite(dynamic item) async {
    final db = await database;
    final type = item is Movie ? 'movie' : 'tv';
    final data = {
      'id': item.id,
      'type': type,
      'title': item.title,
      'poster': item.poster,
      'overview': item.overview,
      'rating': item.rating,
      'releaseDate': type == 'movie' ? item.releaseDate : item.firstAirDate,
      'data': jsonEncode(item.toJson()),
    };

    await db.insert('favorites', data,
        conflictAlgorithm:
            ConflictAlgorithm.replace); //remplace en cas de conflit
  }

  //supprime un favori de la db
  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // vrifier si qlq est un favori
  Future<bool> isFavorite(int id) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty; //retourne true si le favori est trouvé
  }

  //recuperer tous les favoris
  Future<List<dynamic>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('favorites'); //recuperation des favoris

    return maps.map((map) {
      final data = jsonDecode(map['data']);
      if (map['type'] == 'movie') {
        return Movie.fromJson(data);
      } else {
        return TvSeries.fromJson(data);
      }
    }).toList(); //retourne la liste des favoris
  }

  //==================================================

  //mettre a jour la note et la critique personnelle
  Future<void> updateUserRating(
      //mettre a jour la note utilisateur
      int id,
      double rating,
      String? review) async {
    //id du media, note, critique
    final db = await database;
    await db.update(
      'favorites',
      {
        'userRating': rating,
        'userReview': review,
      },
      where: 'id = ?',
      whereArgs: [id], //arguments de la condition
    );
  }

  //marquer un episode comme vu
  Future<void> markEpisodeAsWatched(
      int seriesId, int seasonNumber, int episodeNumber, bool watched) async {
    final db = await database;
    await db.insert(
      'episode_progress',
      {
        'series_id': seriesId,
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
        'watched': watched ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, //remplace en cas de conflit
    );
  }

  //verifier si un episode est vu
  Future<bool> isEpisodeWatched(
      int seriesId, int seasonNumber, int episodeNumber) async {
    final db = await database;
    final result = await db.query(
      'episode_progress',
      where: 'series_id = ? AND season_number = ? AND episode_number = ?',
      whereArgs: [
        seriesId,
        seasonNumber,
        episodeNumber
      ], //arguments de la condition
    );
    return result.isNotEmpty && result.first['watched'] == 1;
  }
}
