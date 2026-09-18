import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/core/theme/app_colors.dart';

import '../core/exception/server_exception.dart';

class ErrorStateWidget extends StatelessWidget{

  final Object  statusCode ;
  final VoidCallback onRetry;

  ErrorStateWidget({
   required this.statusCode ,
   required this.onRetry
});

  @override
  Widget build(BuildContext context) {

    String error_description ='', image ='';

    if (statusCode is SocketException) {
      image = "no_connection.svg";
      error_description = "No Internet Connection";

    }else if (statusCode is ServerException) {

      final  error_code = statusCode as ServerException;

      switch (error_code.statusCode) {
        case 500:
          error_description = "Server problem!";
          image = "server_error.svg";
          break;
        case 404 :
          error_description = "Server problem!";
          image = "page_not_found.svg";
          break;
        default:
          image = "error.svg";
          error_description = "Something went wrong";
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$error_description",style: GoogleFonts.neuton(color: Colors.white,fontSize: 17),),
          SvgPicture.asset('assets/$image'),
          InkWell(
            onTap: (){
              onRetry();
            },
            child: Text("RESTART",style: TextStyle(color: Colors.white),)
          ),

        ],
      ),
    );

  }

}