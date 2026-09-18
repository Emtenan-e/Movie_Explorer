import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movie_explorer/models/movie_model.dart';

import '../core/constant/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../screens/movie_page.dart';
import 'movie_genres_chips.dart';

class WatchListWidget extends StatefulWidget{

  MovieModel movie ;

  WatchListWidget({
    required this.movie
});

  @override
  State<WatchListWidget> createState() => _WatchListWidgetState();
}

class _WatchListWidgetState extends State<WatchListWidget> {
  List<int> watchList = [];
  var box ;

  @override
  void initState() {
    super.initState();

    box = Hive.box('myMoviesBox');
    //get list from Hive
    watchList = box.get('watchList', defaultValue: <int>[]);

  }


  @override
  Widget build(BuildContext context) {

    double rate = double.parse(widget.movie.vote_average.toStringAsFixed(1));
    List<int> genresId = widget.movie.genre_ids;
    List<String> genresList = genresId.map((id)=>AppConstants.genresMap[id]??"Unknown").take(2).toList();

    List<String>? genresString = widget.movie.genres;

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1.6),
        child: Container(
          color: AppColors.backgroundLight.withOpacity(0.6),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.movie.poster_path != '' ? Image.network("https://image.tmdb.org/t/p/w154${widget.movie.poster_path}",
                fit: BoxFit.cover,height: 100,)
                  : Image.asset("assets/poster.png",fit: BoxFit.contain,height: 100,width: 70,),

              //movie details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.movie.title}",
                        style: GoogleFonts.oswald(color: Colors.white,fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                      ),
                      SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      Transform.scale(
                          scale: 0.8,
                          alignment: Alignment.centerLeft,
                          child:MovieGenresChips(
                            genresList:(genresString != null && genresString.isNotEmpty)
                                ? genresString.take(2).toList()
                                : genresList,)
                      )

                    ],
                  ),
                ),
              ),


              IconButton(
                  onPressed: (){

                    watchList.remove(widget.movie.id);
                    box.put("watchList", watchList.toList());

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Deleted!",style: GoogleFonts.neuton(color: Colors.white),),
                            duration: Duration(seconds: 2),
                            backgroundColor: AppColors.backgroundLight.withOpacity(0.5),
                            behavior: SnackBarBehavior.floating,

                        )
                    );


                  },
                  icon: Icon(Icons.delete,color: AppColors.red_,size: 20,)
              )

            ],
          ),
        ),
      ) ,
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MoviePage(id: widget.movie.id,)));

      },
    );
  }
}