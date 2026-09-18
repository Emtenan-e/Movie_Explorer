import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer/models/movie_model.dart';
import 'package:movie_explorer/services/movie_service.dart';
import 'package:movie_explorer/widgets/watch_list_widget.dart';
import '../core/theme/app_colors.dart';
import '../widgets/error_state_widget.dart';

class WatchListPage extends StatefulWidget {



  @override
  State<WatchListPage> createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {

  List<int> watchList = [];
  List<MovieModel> favoriteMovies = [] ;
   Future<List<MovieModel>> watchListFuture= Future.value([]);

  @override
  void initState() {
    super.initState();

    var box = Hive.box('myMoviesBox');
    //get list from Hive
    watchList = box.get('watchList', defaultValue: <int>[]);
    _refreshPage();
  }

  Future<void>  _refreshPage()  async{

    setState(() {

      if (watchList.isEmpty) {
        watchListFuture = Future.value([]);
      } else {
        watchListFuture = Future.wait(
          watchList.map((id) => MovieService().getMovieData(id)).toList(),
        );
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Watch List",style: GoogleFonts.neuton(color: Colors.white,),),
          backgroundColor: AppColors.backgroundLight,
        ),
        backgroundColor: AppColors.background,
        //valueListenable to update watch list page when a movie added to the list
        body: ValueListenableBuilder(
          valueListenable: Hive.box('myMoviesBox').listenable(),
          builder: (context, box, child) {

            final updatedList = List<int>.from(box.get('watchList', defaultValue: []));

            if (updatedList.length != watchList.length) {
              watchList = updatedList;
              if (watchList.isEmpty) {
                watchListFuture = Future.value([]);
              } else {
                watchListFuture = Future.wait(
                  watchList.map((id) => MovieService().getMovieData(id)).toList(),
                );
              }
            }

            if (watchList.isEmpty) {
              return Center(
                child: Text(
                  "Add movie to watch list",style: GoogleFonts.neuton(color: Colors.white),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(top:1),
              child: FutureBuilder<List<MovieModel>>(
                  future:  watchListFuture,
                  builder: (context,snapshot){

                  if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                  }else if(snapshot.hasError){
                    return ErrorStateWidget(
                      statusCode: snapshot.error!,
                      onRetry: (){
                        _refreshPage();
                      },
                    );
                  }

                  //show content of the list
                  List<MovieModel> model = snapshot.data!;


                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: model.length ,
                      itemBuilder: (context,index){
                        final movie = model[index];
                        return WatchListWidget(movie:movie);
                      }
                  );

               }
                  ),
            );
          }
        )
    );

  }




}