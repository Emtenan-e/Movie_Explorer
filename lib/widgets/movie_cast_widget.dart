import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/models/cast_model.dart';

import '../models/company_model.dart';

class MovieCastWidget extends StatelessWidget{

  CastModel cast ;

  MovieCastWidget({
    required this.cast
  });


  @override
  Widget build(BuildContext context) {

    return Container(
      width:  80,
      child: Column(
        children: [
          Container(
            width:60,
            height: 60,
            decoration: BoxDecoration(
              shape:BoxShape.circle,
                color: Colors.grey[800],
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: cast.image != '' ? NetworkImage('https://image.tmdb.org/t/p/w185${cast.image}',)
                      : AssetImage("assets/actor.png")as ImageProvider
              )
            ),
          ),
          SizedBox(height: 5,),
          Text(cast.name,style: GoogleFonts.neuton(color: Colors.white,fontSize: 10),)
        ],
      ),
    );
  }

}
