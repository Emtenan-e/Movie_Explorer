import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:movie_explorer/core/exception/server_exception.dart';
import 'package:movie_explorer/models/cast_model.dart';
import 'package:movie_explorer/models/movie_model.dart';


class MovieService {

  final token = dotenv.env['TMDB_API_KEY'];

  Future<List<MovieModel>> getMovieList (String classification) async{

    try{

      final response = await http.get(

          Uri.parse("https://api.themoviedb.org/3/movie/$classification?include_adult=false&language=en-US&page=1"),
          headers: {
            'Authorization' : 'Bearer $token' ,
            'accept': 'application/json',
          }
      );


      if(response.statusCode==200){
      //decode json file
      Map<String,dynamic> jsonData = jsonDecode(response.body);

      //list from result
      List<dynamic> resultList = jsonData['results'];
      List<MovieModel> moviesList = resultList.map((movie){
        return MovieModel.fromJson(movie);
      }).toList();

      return moviesList;

      }else {
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");
    }

  }
  
  Future<MovieModel> getMovieData(int id) async {

    try{

      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$id?language=en-US'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          });

      if(response.statusCode==200){

        Map<String,dynamic> movieData = jsonDecode(response.body);

        return MovieModel.fromJson(movieData) ;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");

    }

  }

  Future<List<CastModel>> getCast(int movie_id) async{
    try{

      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$movie_id/credits?language=en-US'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          });

      if(response.statusCode==200){

        Map<String,dynamic> castData = jsonDecode(response.body);
        List<dynamic> cast = castData['cast'];

        List<CastModel> castList = cast.map((cast){
          return CastModel.fromJson(cast);
        }).toList();

        return castList;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");

    }
  }

  Future<String> getMovieVideo(int id) async {

    try{

      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$id/videos?language=en-US'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          });


      if(response.statusCode==200){

        //decode json file
        Map<String,dynamic> jsonData = jsonDecode(response.body);

        //list from result
        List<dynamic> resultList = jsonData['results'];

        //get the key from the list by filtering , orElse not found return '' empty
        String key = (resultList.firstWhere((test) => test['type'] != null && test['type'] == "Trailer" ,
          orElse: () => {'key': ''},)['key']??'')as String ;



        return key;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");

    }

  }

Future<List<MovieModel>> getCollectionList(int id)async{
    try{

      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/collection/$id'),
      headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      });


      if(response.statusCode==200){
        Map<String,dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> parts = jsonData['parts'];
        List<MovieModel> moviesList = parts.map((movie){
          return MovieModel.fromJson(movie);
        }).toList();

        return moviesList;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }
    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");
    }
}

Future<List<MovieModel>> getUpComing() async{
    try{
      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/upcoming?include_adult=false&language=en-US&page=1'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          });

      if(response.statusCode==200){
        Map<String,dynamic> upComingMap = jsonDecode(response.body);
        List<dynamic> resultList = upComingMap["results"];
        List<MovieModel> movieList = resultList.map((movie){
          return MovieModel.fromJson(movie);
        }).toList();

        return movieList;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");
    }
}

Future<List<MovieModel>> searchByKeyword(String query,String pageNumber) async {

    try {

      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/search/movie?include_adult=false&language=en-US&page=$pageNumber&query=${Uri.encodeComponent(query)}'),
          headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          });

      if(response.statusCode==200){
        Map<String,dynamic> search = jsonDecode(response.body);
        List<dynamic> resultList = search["results"];
        List<MovieModel> movieList = resultList.map((movie){
          return MovieModel.fromJson(movie);
        }).toList();

        return movieList;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }


    }catch(e){
      if(e is http.ClientException|| e is SocketException||
          e is ServerException ){
        rethrow;
      }

      throw Exception("something wrong");
    }
}

Future<List<MovieModel>> searchByGenre(String genre,String pageNumber) async{
    try{
      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?with_genres=$genre&include_adult=false&language=en-US&page=$pageNumber'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          });
      if(response.statusCode==200){
        Map<String,dynamic> search = jsonDecode(response.body);
        List<dynamic> resultList = search["results"];
        List<MovieModel> movieList = resultList.map((movie){
          return MovieModel.fromJson(movie);
        }).toList();

        return movieList;

      }else{
        throw ServerException(statusCode: response.statusCode);
      }

    }catch(e){
      if(e is http.ClientException || e is ServerException || e is SocketException){
        rethrow;
      }

      throw Exception("something wrong");
    }
}

}