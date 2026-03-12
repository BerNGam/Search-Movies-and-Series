# Search-Movies-and-Series

Une application Flutter permettant de découvrir, rechercher et suivre des films et séries TV, avec des fonctionnalités de gestion des favoris et de suivi des épisodes.

## Services Utilisés
### 1. API TMDB (The Movie Database)
Pour récupérer les informations sur les films et séries :
- Base URL: `https://api.themoviedb.org/3`
- Endpoints utilisés :
    - `/search/movie` : Recherche de films
    - `/search/tv` : Recherche de séries
    - `/movie/{id}` : Détails d'un film
    - `/tv/{id}` : Détails d'une série
    - `/tv/{id}/season/{season_number}` : Détails d'une saison
    - `/person/{id}` : Détails d'un acteur/personnel
    - `/person/{id}/combined_credits` : Filmographie d'un acteur
    - `/movie/{id}/recommendations` : Films recommandés
    - `/tv/{id}/recommendations` : Séries recommandées

### 2. CDN TMDB pour les Images
Service d'hébergement et de distribution des images :
- Base URL: `https://image.tmdb.org/t/p/`
- Formats disponibles :
    - `w200` : Petites images (affiches dans les listes, photos de profil)
    - `w500` : Grandes images (affiches détaillées)
- Types d'images :
    - Affiches de films (`poster_path`)
    - Affiches de séries (`poster_path`)
    - Photos de profil d'acteurs (`profile_path`)

## Fonctionnalités Principales
### 1. Navigation
- Interface avec barre de navigation inférieure (Home, Recherche, Favoris)

### 2. Découverte de Contenu
- Affichage des films et séries populaires sur la page d'accueil
- Système de recommandations basé sur les favoris de l'utilisateur
- Visualisation détaillée des films et séries avec :
    - Synopsis
    - Note moyenne
    - Distribution
    - Critiques
    - Contenus similaires

### 3. Gestion des Favoris
- Ajout/suppression de films et séries aux favoris
- Stockage local avec SQLite
- Visualisation des favoris dans une section dédiée

### 4. Suivi des Épisodes (Spécificité Originale)
- Système de suivi des épisodes vus par saison
- Interface intuitive avec cases à cocher
- Progression sauvegardée localement
- Visualisation du progrès par saison

### 5. Système de Notes et Critiques
- Possibilité de noter les films et séries (échelle de 1 à 5 étoiles)
- Ajout de critiques personnelles
- Stockage local des avis

### 6. Détails des Acteurs/Personnel
- Pages dédiées pour chaque acteur/membre du personnel
- Biographie
- Filmographie interactive
- Navigation vers les films/séries associés

## Spécificités Techniques
### Base de Données
- Utilisation de SQLite pour le stockage local
- Tables :
    - `favorites` : Stockage des favoris
    - `episode_progress` : Suivi des épisodes visionnés
    - Support des notes et critiques utilisateur

### Architecture
- Utilisation du pattern Provider pour la gestion d'état
- Services dédiés pour les appels API
- Helpers pour la gestion de la base de données

## Limitations
1. **Gestion Hors-ligne**
    - L'application nécessite une connexion internet pour la plupart des fonctionnalités
    - Pas de mise en cache des données pour une utilisation hors-ligne
    - Pas de système de cache pour les images

2. **Authentification**
    - Pas de système de compte utilisateur
    - Données sauvegardées uniquement en local

3. **Base de donnée**
    - SQLite fonctionne que sur support mobile
    - Problème de chargement de données si application lancée sur le web

4. **Filtres et Tri**
    - Options de filtrage limitées
    - Pas de tri personnalisé des résultats

## Dépendances Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.0.0  # Base de données SQLite
  provider: ^6.0.0  # Gestion d'état
  http: ^0.13.0    # Appels API
  path: ^1.8.0     # Gestion des chemins
```

## Installation et Configuration
1. Lancer la création d'un nouveau projet : `flutter create projetmovie`
2. Remplacer `pubspec.yaml` par celui de ce dossier
3. Remplacer le répertoire `lib` par celui de ce dossier
4. Installer les dépendances : `flutter pub get`
5. Configurer votre clé API TMDB dans `film_service.dart` si besoin il y'a
6. Lancer l'application : `flutter run`

NB : Toutes les fonctionnalités de l'application ne fonctionne que sur un émulateur android mobile, sur le web (chrome, edge ou autres ) sqlite pose problème.
