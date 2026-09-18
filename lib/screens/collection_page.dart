import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_explorer/services//movie_service.dart';

import '../core/theme/app_colors.dart';
import '../models/movie_model.dart';
import '../widgets/movie_poster.dart';

class CollectionPage extends StatefulWidget{

  int collectionId ;
  String collectionName;
  String? tagline , backdrop  ;
//collection name and backdrop

  CollectionPage({
    required this.collectionId,
    this.tagline,
    required this.collectionName,
    this.backdrop
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {

  late Future <List <MovieModel>> movieCollection ;



  @override
  void initState() {
    super.initState();
    movieCollection = MovieService().getCollectionList(widget.collectionId);
  }

  @override
  Widget build(BuildContext context) {

    String name = widget.collectionName.replaceAll("Collection", "").trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 150.0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.only(left:5,right: 5),
                child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:"$name\n",
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15)
                        ),
                        TextSpan(
                            text:"${widget.tagline}",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white.withOpacity(0.5),fontSize: 10)
                        )
                      ]
                    )
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network("https://image.tmdb.org/t/p/w780${widget.backdrop}",fit: BoxFit.cover,),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )
            ),
          ),


          SliverToBoxAdapter(
            child: SizedBox(height: 20,),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            sliver: FutureBuilder<List<MovieModel>>(
                future: movieCollection,
                builder: (context,snapshot){

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(),));
                  }else if(snapshot.hasError){
                    return SliverToBoxAdapter(child: Center(child: Text("${snapshot.error}")));
                  }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text("No movies found", style: TextStyle(color: Colors.white))),
                    );
                  }

                  List <MovieModel> movieList = snapshot.data! ;
                  return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final movie = movieList[index];
                          return Center(
                            child: SizedBox(
                              width: 100,
                              child: MoviePoster(movie: movie,showGenres: false,),
                            ),
                          );
                        },
                        childCount: movieList.length,
                      ),

                  );
                }
            )

          )

        ],
      )
    );
  }
}