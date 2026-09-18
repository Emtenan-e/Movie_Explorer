import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer/core/constant/app_constants.dart';
import 'package:movie_explorer/core/theme/app_colors.dart';
import 'package:movie_explorer/models/cast_model.dart';
import 'package:movie_explorer/models/company_model.dart';
import 'package:movie_explorer/models/movie_model.dart';
import 'package:movie_explorer/screens/collection_page.dart';
import 'package:movie_explorer/services/movie_service.dart';
import 'package:movie_explorer/widgets/movie_companies_widget.dart';
import 'package:movie_explorer/widgets/movie_countries_flag.dart';
import 'package:movie_explorer/widgets/movie_genres_chips.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/movie_cast_widget.dart';
import '../widgets/movie_poster.dart';

class MoviePage extends StatefulWidget {

  int id ;

  MoviePage({
    super.key,
    required this.id
  });

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> with SingleTickerProviderStateMixin {

  late Future<MovieModel> futureData ;
  late Future<String> videoKey;
  late Future <List <MovieModel>> futureSimilar ;
  late Future <List<CastModel>> futureCast ;
  late YoutubePlayerController _youtubeController ;

  List <int> watchList  = [] ;
  var box ;
  bool isPressed = false ;
  late TabController _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();

    box = Hive.box('myMoviesBox');
    watchList = box.get('watchList', defaultValue: <int>[]);

    isPressed = watchList.contains(widget.id);

    futureData = MovieService().getMovieData(widget.id);
    videoKey = MovieService().getMovieVideo(widget.id);

    futureCast = MovieService().getCast(widget.id) ;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }


  Future<void> _openMovieLink(String urlString) async {

    final Uri url = Uri.parse(urlString);

    //check if url work
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sorry, the movie link could not be opened !",style: GoogleFonts.neuton(color: Colors.white),),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.backgroundLight,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = screenWidth * 0.40;   //40% of screen width

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FutureBuilder<MovieModel>(
            future: futureData,
            builder: (context,snapshot){

              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }else if(snapshot.hasError){
                return Center(child: Text("${snapshot.error}"));
              }
      
              MovieModel model = snapshot.data! ;
              double rating = model.vote_average/2;

              List<String> genres = model.genres!;
              List <String> countriesList = model.production_countries! ;

              String date = model.release_date.split("-").first;
              List <CompanyModel> companiesList = model.production_companies ??[] ;

              futureSimilar = MovieService().getMovieList("${model.id}/similar");

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //backdrop and poster
                    Stack(
                      //allow poster to get outside the backdrop
                      clipBehavior: Clip.none,
                      children: [
                        //backdrop and play Trailer icon button
                        Stack(
                          alignment: Alignment.center,
                          children:[
                            SizedBox(
                                height: 250,
                                child: model.backdrop_path !='' ? Image.network("https://image.tmdb.org/t/p/w780${model.backdrop_path}" ,
                                  fit: BoxFit.cover,) : Center(child: Image.asset("assets/backdrop.png",fit: BoxFit.cover,))
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
                                      Colors.black.withOpacity(0.7), // Fades to dark black at the bottom
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                                top: 4,left: 4,
                                child: IconButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                    },
                                  icon: Icon(Icons.arrow_back,color: Colors.white,),
                                )
                            ),

                            //get triller key
                            FutureBuilder<String>(
                              future: videoKey,
                              builder: (context,snapshot){
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return Center(child: CircularProgressIndicator(),);
                                }else if(snapshot.hasError){
                                  return Center(child: Text("${snapshot.error}"));
                                }else if(!snapshot.hasData || snapshot.data==''){
                                  return SizedBox.shrink();
                                }

                                String key = snapshot.data! ;

                                return IconButton(
                                    onPressed: (){

                                      _youtubeController =YoutubePlayerController.fromVideoId(
                                        videoId: key,
                                        autoPlay: true,
                                        params: const YoutubePlayerParams(
                                          mute: false,
                                          showControls: true,
                                          showFullscreenButton: true,
                                        ),
                                      );

                                      showVideoDialog(context,_youtubeController);
                                    },

                                    icon:Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 60,
                                    ));

                              },
                            )
                          ] 
                        ),

                        //poster
                        Positioned(
                          left: 30,bottom: -110,
                          child: SizedBox(
                            height: 200,
                              child: Container(
                                width: posterWidth, height: screenWidth*0.33,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white,width: 2),
                
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                
                                  image:DecorationImage(
                                    image: model.poster_path !='' ? NetworkImage("https://image.tmdb.org/t/p/w154${model.poster_path}") :
                                      AssetImage("assets/poster.png")as ImageProvider ,fit: BoxFit.contain ),
                                )
                              )
                          ),
                        ),

                      ],
                    ),
                
                    // movie name, date and rate
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //leaving space of poster width
                          SizedBox(width: posterWidth+15),
                          Expanded(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //movie name and language
                                  RichText(
                                      text: TextSpan(
                                        children:[
                                          TextSpan(
                                            text: "${model.title} - ",
                                            style: GoogleFonts.oswald(fontSize: 16,color: Colors.white)
                                          ),
                                          TextSpan(
                                              text: "${model.language}",
                                              style: GoogleFonts.neuton(fontSize: 16,color: Colors.white)
                                          ),
                                        ]
                                      )
                                  ),
                                  SizedBox(height: 5,),

                                  //movie status, release date and countries
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      model.status == "Released" ?
                                      Text("$date - ",style: GoogleFonts.neuton(color: Colors.white,fontSize: 10))
                                          : Text("${model.status}", style: GoogleFonts.neuton(color: Colors.white,fontSize: 10)),
                                      SizedBox(width: 5,),
                                      MovieContriesFlag(countries: countriesList)

                                    ],
                                  ),

                                  SizedBox(height: 5,),
                                  //rating stars
                                  SmoothStarRating(
                                    allowHalfRating: true,
                                      starCount: 5,
                                      rating: rating,
                                      size: 20.0,
                                      color: AppColors.starRate,
                                      borderColor: Colors.white,
                                      spacing:0.0
                                  ),

                                ],
                              ),
                            ),
                          ),
                
                        ],
                      ),
                    ),

                    //overview,cast and companies
                    const SizedBox(height: 40),
                    TabBar(
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(text: "About"),
                        Tab(text: "Cast",),
                        Tab(text: "Companies",),
                      ],
                      labelColor: AppColors.blueSky_,
                      indicatorColor: AppColors.blueSky_,
                      labelStyle: GoogleFonts.neuton(fontSize: 14),

                    ),
                    Container(
                      height: 150,
                      color: AppColors.backgroundLight.withOpacity(0.4),
                      child: IndexedStack(
                        index: tabIndex,
                        children: [
                        //about movie
                          _about(model),

                        //casting
                          getCasting(futureCast,context),


                        //Companies
                          if( companiesList.isNotEmpty)
                            _companies(companiesList),

                          //if no companies
                          if (companiesList.isEmpty)
                          Center(
                          child: Text(
                          "No production companies available",
                          style: TextStyle(color: Colors.white),
                          ),
                          )

                        ],
                      ),
                    ),

                    SizedBox(height: 15,),
                    //genres
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: MovieGenresChips(genresList: genres),
                    ),

                    //shar and save
                    SizedBox(height: 10,),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      //share
                      child: Row(
                        children: [
                          Row(
                            children: [
                              InkWell(
                                child: CircleAvatar(
                                  child: Icon(Icons.share,color: AppColors.blueSky_,size: 20,),
                                  radius: 15,
                                  backgroundColor: AppColors.backgroundLight,
                                ),
                                onTap: ()=> _shareMovie(model) ,
                              ),
                              SizedBox(width: 4,),

                              Text("Share",style: GoogleFonts.neuton(color:Colors.white,fontSize: 13))
                            ],
                          ),
                          SizedBox(width: 10,),

                          //save
                          Row(
                            children: [
                              InkWell(
                                child: CircleAvatar(
                                    child: SvgPicture.asset(
                                      'assets/icons/bookmark.svg',
                                      width: 14,height: 14,
                                      color: isPressed? AppColors.starRate:Colors.white.withOpacity(0.7),),
                                    radius: 15,
                                    backgroundColor: AppColors.backgroundLight
                                ),
                                onTap: () async {

                                  setState(() {
                                    isPressed = !isPressed;
                                  });


                                  if(isPressed){
                                    watchList.add(widget.id);
                                    box.put("watchList", watchList.toList());

                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Added to watch list !",style: GoogleFonts.neuton(color: Colors.white),),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: AppColors.backgroundLight,
                                            behavior: SnackBarBehavior.floating,
                                        )
                                    );

                                  }else{
                                    watchList.remove(widget.id);
                                    box.put("watchList", watchList.toList());

                                  }

                                },

                              ),
                              SizedBox(width: 4,),
                              Text("Watch list",style: GoogleFonts.neuton(color:Colors.white,fontSize: 13),)
                            ],
                          )
                        ],
                      )
                    ),


                
                    //collection
                    SizedBox(height: 20,),
                    if(model.collectionName != 'Single Movie')
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: InkWell(
                          child: Container(
                            width: posterWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //collection poster
                                Container(
                                    width: posterWidth, height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white,width: 1),


                                      image:DecorationImage(
                                          image : model.collection_poster != '' ? NetworkImage("https://image.tmdb.org/t/p/w154${model.collection_poster}")
                                              : AssetImage("assets/poster.png")as ImageProvider,
                                          fit: BoxFit.contain ),

                                    ),

                                ),
                                SizedBox(height: 7,),
                                Text("${model.collectionName}",style: GoogleFonts.neuton(color:AppColors.link_,fontSize: 12),textAlign: TextAlign.center,),
                          
                              ],
                            ),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=> CollectionPage(
                                  collectionId: model.collectionId!,
                                  tagline: model.tagline,
                                  collectionName: model.collectionName!,
                                  backdrop: model.collection_backdrop,)
                            ));
                          },
                        ),
                      ),

                    //Similar movie
                    SizedBox(height: 10,),
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(
                    color: Colors.white.withOpacity(0.5),
                    thickness: 1,),
                    ),
                    Center(child: Text("Similar Movies",style: GoogleFonts.ephesis(color: Colors.white,fontSize: 23),)),
                    SizedBox(height: 10,),

                    //similar movie
                    FutureBuilder<List<MovieModel>>(
                        future: futureSimilar,
                        builder: (context,snapshot){

                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator(),);
                          }else if(snapshot.hasError){
                            return Center(child: Text("${snapshot.error}"));
                          }

                          List <MovieModel> movieList = snapshot.data! ;
                          return SizedBox(
                            width: screenWidth,
                            height: AppConstants.posterHeight,
                            child: ListView.builder(
                             scrollDirection: Axis.horizontal,
                              itemCount: movieList.length,
                              itemBuilder: ((context,index){
                                final movie = movieList[index] ;


                                return Padding(
                                  padding: const EdgeInsets.only(left: 4.0,right: 4.0),
                                  child: MoviePoster(movie: movie),
                                );
                              })
                            )
                          );


                        }),


                  ],
                ),
              );
      
      
            }),
      ),
    );
  }

  Widget _companies(List<CompanyModel> companiesList) {
    return SizedBox(
        height: 120,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: companiesList.length,
            itemBuilder: ((context,index){
              final company = companiesList[index] ;
              return Padding(
                padding: const EdgeInsets.only(left: 8.0,top: 8),
                child: MovieCompaniesWidget(company: company),
              );
            })
        )
    );
  }

  Widget _about(MovieModel model) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,top: 8),
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start ,
        children: [
          Text("${model.title}:",style: GoogleFonts.oswald(color:AppColors.red_,fontSize: 13),),
          Text("${model.overview}",
              style: TextStyle(color: Colors.white,fontSize: 10.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
          ),

          if(model.overview.length>200)
            TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                            title: Text(model.title),
                            titleTextStyle: TextStyle(fontSize: 13,color: Colors.white),
                            backgroundColor: AppColors.backgroundLight,
                            content: SingleChildScrollView(
                              child: Text(
                                model.overview,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                        );
                      }
                  );
                },
                child: Text(
                  "read more",
                  style: GoogleFonts.neuton(color: Colors.white,fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.red_,
                  ),

                )
            ),

          SizedBox(height: 10,),
          //movie homepage
          if(model.movie_homepage != '')
            TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                onPressed: (){
                  _openMovieLink(model.movie_homepage!);
                },
                child: Text("Visit movie site", style: GoogleFonts.neuton(color: AppColors.blueSky_,fontSize: 12),)
            )


        ],
      ),
    );
  }

 getCasting(Future <List<CastModel>> castFuture, BuildContext context){

     return FutureBuilder<List<CastModel>>(
        future: castFuture,
        builder: (context,snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }else if(snapshot.hasError){
            return Center(child: Text("${snapshot.error}"));
          }

          if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text("-",style: GoogleFonts.neuton(color: Colors.white)));
          }
          List <CastModel> castList = snapshot.data! ;
          final displayCast = math.min(castList.length, 15);


          return SizedBox(
              height: 100,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayCast,
                  itemBuilder: ((context,index){
                    final casting = castList[index] ;


                    return Padding(
                      padding: const EdgeInsets.only(left:8,top: 10),
                      child: MovieCastWidget(cast: casting),
                    );
                  })
              )
          );


        });



}

  void showVideoDialog(BuildContext context,YoutubePlayerController youtubeController) {
    showDialog(
        context: context,
        builder: (BuildContext context){

          return Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.symmetric(horizontal: 12),
              child: Theme(
                data: ThemeData(
                  extensions: [
                    YoutubePlayerTheme(
                      progressBarActiveColor: AppColors.red_,
                      progressBarBufferedColor:AppColors.red_.withOpacity(0.3),
                      progressBarBackgroundColor:AppColors.link_,
                      controlsColor:Colors.white,

                    ),

                  ],
                ),

                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),

                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: YoutubePlayer(
                          controller: youtubeController,
                        ),
                      ),
                    ],
                  ),
                ),
              )

          );
        });
  }

  void _shareMovie(MovieModel model){

    //TODO check rate

    final String message = ''' 🎬 Watch ${model.title}\n
    ⭐ ${model.vote_average/2} / 5 Rating \n
    📝 Story : ${model.overview}
     ''';

    Share.share(message) ;

  }


}