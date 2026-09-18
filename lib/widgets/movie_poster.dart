import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constant/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/movie_model.dart';
import '../screens/movie_page.dart';
import 'movie_genres_chips.dart';

class MoviePoster extends StatefulWidget {

  MovieModel movie;
  bool showGenres;

  //TODO remove gradiant

  MoviePoster({
    required this.movie,
    this.showGenres = true
});


  @override
  State<MoviePoster> createState() => _MoviePosterState();
}

class _MoviePosterState extends State<MoviePoster> {
  @override
  Widget build(BuildContext context) {

    double rate = double.parse(widget.movie.vote_average.toStringAsFixed(1));
    List<int> genresId = widget.movie.genre_ids;
    List<String> genresList = genresId.map((id)=>AppConstants.genresMap[id]??"Unknown").take(2).toList();

    List<String>? genresString = widget.movie.genres;

    return InkWell(
      splashColor: Colors.white.withOpacity(0.1),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MoviePage(id: widget.movie.id,)));
      },
      child: Stack(
        children: [
          //poster
         widget.movie.poster_path != '' ? Image.network("https://image.tmdb.org/t/p/w154${widget.movie.poster_path}",
              fit: BoxFit.cover,height: AppConstants.posterHeight,):
          Image.asset("assets/poster.png",fit: BoxFit.cover , height: AppConstants.posterHeight),

          //gradiant
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5), // Fades to dark black at the bottom
                  ],
                ),
              ),
            ),
          ),

          //rated value and genres
          Positioned(
            left: 5, bottom:5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.starRate,
                      size: 16,
                    ),
                    SizedBox(width: 2,),
                    Text("$rate ~",style: TextStyle(fontSize: 9.5,color: Colors.white),),

                  ],
                ),

                //genres
                if(widget.showGenres)
                  Transform.scale(
                    scale: 0.8,
                    alignment: Alignment.centerLeft,
                    child:MovieGenresChips(
                      genresList:(genresString != null && genresString.isNotEmpty)
                          ? genresString.take(2).toList()
                          : genresList)
                )


              ],
            ),
          )


        ],
      ),
    );
  }
}