import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_explorer/models/movie_model.dart';

import '../core/constant/app_constants.dart';
import 'movie_genres_chips.dart';

class MovieUpcoming extends StatefulWidget{

  MovieModel movie ;

  MovieUpcoming ({
   required this.movie
});

  @override
  State<MovieUpcoming> createState() => _MovieUpcomingState();
}

class _MovieUpcomingState extends State<MovieUpcoming> {
  @override
  Widget build(BuildContext context) {

    List<int> genresId = widget.movie.genre_ids;
    List<String> genresList = genresId.map((id)=>AppConstants.genresMap[id]??"Unknown").take(2).toList();
    List<String>? genresString = widget.movie.genres;


    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 270,
        width: double.infinity,
        child: Stack(
          children: [

            //poster with foggy
            Positioned.fill(
              child: Image.network(
                "https://image.tmdb.org/t/p/w342${widget.movie.poster_path}",
                fit: BoxFit.cover,
              ),
            ),

            //poster
            Positioned.fill(
              child: Image.network(
                "https://image.tmdb.org/t/p/w780${widget.movie.poster_path}",
                fit: BoxFit.contain,
              ),
            ),

            //gradiant
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            //Genres
            Positioned(
              bottom: 10,
              left: 8,
              child: Transform.scale(
                scale: 0.8,
                alignment: Alignment.centerLeft,
                child: MovieGenresChips(
                  genresList: (genresString != null && genresString.isNotEmpty)
                      ? genresString.take(2).toList()
                      : genresList,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}