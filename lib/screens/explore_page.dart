
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/core/constant/app_constants.dart';
import 'package:movie_explorer/core/theme/app_colors.dart';
import 'package:movie_explorer/models/movie_model.dart';
import 'package:movie_explorer/services/movie_service.dart';
import 'package:movie_explorer/widgets/error_state_widget.dart';
import 'package:movie_explorer/widgets/movie_poster.dart';
import 'package:movie_explorer/widgets/movie_upcoming.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'movie_page.dart';


class ExplorePage extends StatefulWidget {

  final ValueNotifier<int> scrollNotifier;

  ExplorePage({required this.scrollNotifier});


  @override
  State<ExplorePage> createState() => _ExplorePage();
}

class _ExplorePage extends State<ExplorePage> {

  final ScrollController _scrollController = ScrollController();

  late Future<List<List<MovieModel>>> allMoviesFuture;

  late Future<List<MovieModel>> upComing ;

  late PageController pageController ;

  @override
  void initState() {
    super.initState();

    widget.scrollNotifier.addListener(_handleScrollAndRefresh);

    allMoviesFuture = Future.wait([
      MovieService().getMovieList("popular"),
      MovieService().getMovieList("top_rated")
    ]);

    upComing = MovieService().getUpComing();

    pageController = PageController(viewportFraction: 0.8, initialPage: 0,);


  }

  void _handleScrollAndRefresh() {
    if (_scrollController.hasClients) {

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        _refreshPage();
      });
    }
  }

  @override
  void dispose() {
    widget.scrollNotifier.removeListener(_handleScrollAndRefresh);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void>  _refreshPage()  async{

    setState(() {

      upComing = MovieService().getUpComing();

      allMoviesFuture = Future.wait([
        MovieService().getMovieList("popular"),
        MovieService().getMovieList("top_rated")
      ]);
    });
  }


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff18121e),
      // backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 30,),
              FutureBuilder<List<MovieModel>>(
                  future: upComing,
                  builder: (context,snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return SizedBox();
                    }else if(snapshot.hasError){

                      return ErrorStateWidget(
                        statusCode: snapshot.error!,
                        onRetry: () => _refreshPage(),
                      );


                    }

                    if(!snapshot.hasData || snapshot.data!.isEmpty|| snapshot.data == null){
                      return Center(child: SvgPicture.asset('assets/no_data.svg'),);
                    }


                    List <MovieModel> listModels = snapshot.data! ;
                    final displayCount = math.min(listModels.length, 15);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity , height: 270,

                          child: PageView.builder(
                              itemCount: displayCount,
                              scrollDirection: Axis.horizontal,
                              controller: pageController ,
                              onPageChanged: handlePageChange,
                              itemBuilder: (context,index){
                                final movie = listModels[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                  child: InkWell(
                                      child: MovieUpcoming(movie: movie),
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MoviePage(id: movie.id,)));
                                      },
                                  ),
                                );

                              }),
                        ),

                        SizedBox(height: 5,),

                        SmoothPageIndicator(
                        controller: pageController,
                        count: 15,
                        effect:  WormEffect(
                            activeDotColor: AppColors.orange_,
                            spacing: 3,
                            dotHeight: 8,
                          dotColor: Colors.white.withOpacity(0.3),
                        ),
                        onDotClicked: (index){
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        )

                    ],
                    );

                  }
                ),

              //list of top rated, popular ... movies
              getListOfMovies(allMoviesFuture,context,_refreshPage),

            ],
          ),
        ),
      ),

    );
  }


  void handlePageChange(int value) {

  }


}

class classificationsStyle extends StatelessWidget {

  final String text ;

  const classificationsStyle(this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,bottom: 8.0),
      child: Text(text,style: GoogleFonts.ephesis(color: Colors.white,fontSize: 23),),
    );
  }
}


Widget getListOfMovies (Future<List<List<MovieModel>>> future, BuildContext context,Future<void> Function()  refresh ) {

  double screenWidth = MediaQuery.of(context).size.width;

  return FutureBuilder<List<List<MovieModel>>>(
      future: future,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: Column(
            children: [
              Center(child: CircularProgressIndicator(),),
              Text("Loading..",style: TextStyle(color: Colors.white),),
            ],
          ),);
        }else if(snapshot.hasError){

          return ErrorStateWidget(
            statusCode: snapshot.error!,
            onRetry: () => refresh(),
          );
        }

        if(!snapshot.hasData || snapshot.data!.isEmpty|| snapshot.data == null){
          return Center(child: SvgPicture.asset('assets/no_data.svg'),);
        }

        List <MovieModel> popularList = snapshot.data![0] ;
        List <MovieModel> topRatedList = snapshot.data![1] ;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            classificationsStyle("Popular"),
            listMovieBuilder(popularList,screenWidth),

            SizedBox(height: 10,),
            classificationsStyle("Top Rated"),
            listMovieBuilder(topRatedList,screenWidth),

          ],
        );

      }
  );
}

listMovieBuilder(List<MovieModel> list, double screenWidth) {

  return SizedBox(
    width: screenWidth ,
    height:AppConstants.posterHeight , //height of poster

    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context,index){
          final movie = list[index] ;

          return Padding(
            padding: const EdgeInsets.only(left: 4.0,right: 4.0),
            child: Column(
              children: [

                MoviePoster(movie: movie),
              ],
            ),
          );

        }
    ),
  );
}