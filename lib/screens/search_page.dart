import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_explorer/core/constant/app_constants.dart';
import 'package:movie_explorer/core/exception/server_exception.dart';
import 'package:movie_explorer/models/movie_model.dart';
import 'package:movie_explorer/services/movie_service.dart';
import 'package:movie_explorer/widgets/error_state_widget.dart';
import 'package:movie_explorer/widgets/movie_genres_chips.dart';
import 'package:movie_explorer/widgets/movie_poster.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';


class SearchPage extends StatefulWidget{
  @override
  State<SearchPage> createState() => _SearchPageState();

}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();
  List<String> genresList = AppConstants.genresMap.values.toList();
  Future <List<MovieModel>>? searchBarFuture;
  Future <List<MovieModel>>? searchGenreFuture;

  String currentSelected ="";
  String searchQuery = "";

  var genre;
  int pageNum = 1 ;
  List<MovieModel> allMovies = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();

  }

  Future<void> loadMoreMovies() async {
    // prevent repeated click on load button
    if (isLoading) return;

    setState(() {
      isLoading = true;
      pageNum++;
    });

    List<MovieModel> newMovies = [];

    if (searchQuery.isNotEmpty) {
      newMovies = await MovieService().searchByKeyword(searchQuery, pageNum.toString());
    } else if (genre != null) {
      newMovies = await MovieService().searchByGenre(genre.toString(), pageNum.toString());

    }

    setState(() {
      allMovies.addAll(newMovies);
      isLoading = false;

      //update future
      if (searchQuery.isNotEmpty) {
        searchBarFuture = Future.value(allMovies);
      } else  {
        searchGenreFuture = Future.value(allMovies);
      }

    });
  }


  @override
  Widget build(BuildContext context) {

    final activeFuture = searchBarFuture ?? searchGenreFuture;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body:GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
            searchController.clear();

          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //search section
                Center(
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Colors.white,fontSize: 11),
                      decoration: InputDecoration(

                        filled: true,
                        fillColor: AppColors.backgroundLight,

                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10.0,
                          ),

                          constraints: const BoxConstraints(
                            maxHeight: 40.0,
                            minHeight: 40.0,
                          ),

                          prefixIcon:Icon(Icons.search_rounded,),
                          prefixIconColor: Colors.white,

                          hint: Text('Search Movie ...',style: GoogleFonts.neuton(color: Colors.grey,fontSize: 14),),
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 9),

                          floatingLabelStyle: TextStyle(color: Colors.white),

                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:  Colors.white.withOpacity(0.7),
                                  width: 0.5
                              ),
                            borderRadius: BorderRadius.circular(17)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(17)

                          )


                      ),
                      onSubmitted: (String value){
                        if (value.trim().isEmpty) return;

                        setState(() {
                          pageNum = 1;
                          allMovies.clear();

                          searchGenreFuture = null;
                          currentSelected = "";
                          searchQuery = value.trim();
                          searchBarFuture = MovieService().searchByKeyword(value,pageNum.toString());


                        });
                      },
                      onChanged: (String value){
                        pageNum = 1 ;
                        allMovies.clear() ;

                      },
                    ),
                  ),
                ),

                SizedBox(height: 20,),
                //genres
                Padding(
                  padding: const EdgeInsets.only(left: 8.0,bottom: 8),
                  child: Text("Genres",style: GoogleFonts.neuton(color: Colors.white,fontSize: 15),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:15,right: 15),
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        MovieGenresChips(genresList: genresList,selectedGenre:currentSelected,
                          onSelect:(selectedGenre){
                          setState(() {
                            currentSelected = selectedGenre;
                            searchBarFuture = null ;
                            searchController.clear();

                            Map <int,String> movieGenre = AppConstants.genresMap ;
                            genre = movieGenre.keys.firstWhere(
                                    (key)=>movieGenre[key]==currentSelected);

                            pageNum = 1;
                            allMovies.clear();

                            searchGenreFuture = MovieService().searchByGenre(genre.toString(),pageNum.toString());

                          });


                        },),

                      ],
                    ),
                  ),
                ),


                if (activeFuture == null)
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/poster.png",width: 150,height: 250,),
                        Center(
                          child: Text(
                          "Search for Movies",style: GoogleFonts.neuton(color: Colors.white),
                          ),
                        )
                      ],
                  )
                else
                  showSearchResult(activeFuture,context),


              ],
            ),
          ),
        )
      ),
    );
  }

  showSearchResult(Future<List<MovieModel>>? searchFuture, BuildContext context) {

    return FutureBuilder<List<MovieModel>>(
        future: searchFuture,
        builder: (context,snapshot){

          if(snapshot.connectionState==ConnectionState.waiting && allMovies.isEmpty){
            return Center(child: CircularProgressIndicator(),);
          }else if (snapshot.hasError){
            if(snapshot.error is ServerException ) {

              final serverError = snapshot.error as ServerException;
              return ErrorStateWidget(
                  statusCode: serverError,
                  onRetry:(){
                    // TODO refresh();
                  }
              );
            }
          }else if(!snapshot.hasData || snapshot.data!.isEmpty && allMovies.isEmpty){
            //TODO show nothing
            return Center(child: SvgPicture.asset('assets/no_data.svg'),);
          }

          if (allMovies.isEmpty) {
            allMovies = snapshot.data!;
          }
          


          return Column(
            children: [

              GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 5,
                      childAspectRatio: 0.7
                  ),
                  itemCount: allMovies.length,
                  itemBuilder: (context,index){
                    final movie = allMovies[index];

                    return Center(
                      child: SizedBox(
                        width: 100,
                        child: MoviePoster(movie: movie,showGenres: false,),
                      ),
                    );
                  }
              ),
              SizedBox(height: 3,),
              //load more movie
              isLoading? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ): Stack(
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: isLoading? null :()=> loadMoreMovies(),
                      icon: SvgPicture.asset('assets/see_more.svg',width: 15, height: 15,)
                  ),

                  Positioned(
                    top: 5,left: 4,
                    child:Text("see more",style: TextStyle(color: Colors.white,fontSize: 9,height: 1.0),),
                  )
                ],
              )

            ],
          );

        }
    );

  }


}