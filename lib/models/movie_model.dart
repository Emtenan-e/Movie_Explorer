import 'company_model.dart';

class MovieModel {
  String title, overview, backdrop_path, poster_path, release_date, language;
  bool adult ;
  final List<int> genre_ids;
  int id;
  double vote_average;

  String? status,
      collectionName,
      collection_backdrop,
      collection_poster,
      tagline,
      movie_homepage;


  int? collectionId ;

  final List<CompanyModel>? production_companies;
  final List<String>? genres;
  final List<String>? production_countries;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.backdrop_path,
    required this.poster_path,
    required this.release_date,
    required this.genre_ids,
    required this.vote_average,
    required this.language,
    required this.adult,

    this.status,
    this.collectionName,
    this.collectionId,
    this.collection_backdrop,
    this.collection_poster,
    this.tagline,
    this.movie_homepage,
    this.production_companies,
    this.genres,
    this.production_countries,


  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      vote_average: (json['vote_average'] as num).toDouble(),
      //return list of int
      genre_ids: json['genre_ids']!= null ? List<int>.from(json['genre_ids']).toList() : [],

      title: json['title'] as String,
      overview: json['overview']?.toString() ?? '',
      backdrop_path: json['backdrop_path']?.toString() ?? '',
      poster_path: json['poster_path']?.toString() ?? '',
      release_date: json['release_date']?.toString() ?? '',
      language: json['original_language']?.toString() ?? '',
      adult: json['adult']as bool? ?? false ,

      status: json['status']?.toString() ?? '',
      //check for collection
      collectionName: json['belongs_to_collection']?['name'] ?? 'Single Movie',
      collectionId : json['belongs_to_collection']?['id'] ?? -1 ,
      collection_poster: json['belongs_to_collection']?['poster_path'] ?? '',
      collection_backdrop:
          json['belongs_to_collection']?['backdrop_path'] ?? '',

      tagline: json['tagline']?.toString() ?? '',
      movie_homepage: json['homepage']?.toString() ?? '',

      genres: json['genres']!= null? List<String>.from(
        (json['genres'] as List).map((element) => element['name'].toString()),
      ): [],

      production_countries: json['production_countries'] != null
          ? List<String>.from(
              (json['production_countries'] as List).map(
                (element) => element['iso_3166_1'].toString(),
              ),
            )
          : null,

      production_companies: json['production_companies'] != null
          ? List<CompanyModel>.from(
              (json['production_companies'] as List).map(
                (element) =>
                    CompanyModel.fromJson(element as Map<String, dynamic>),
              ),
            )
          : [],


    );
  }
}


