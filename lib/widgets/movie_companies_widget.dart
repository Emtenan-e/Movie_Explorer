import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/models/company_model.dart';

class MovieCompaniesWidget extends StatelessWidget {

  CompanyModel company ;

  MovieCompaniesWidget({
   required this.company
});

  @override
  Widget build(BuildContext context) {


    return Container(
      width: 80,
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80 , width: 80 ,
              padding: EdgeInsets.all(2),
              color: Colors.white,
              child: company.logo!="" ? Image.network('https://image.tmdb.org/t/p/w780${company.logo}',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,)
                  : Icon(Icons.movie,color: Colors.black,)
          ),
          SizedBox(height: 4,),
          Text("${company.name}",
            style: GoogleFonts.neuton(color: Colors.white,fontSize:10 ),
            textAlign: TextAlign.center,)
        ],
      ),
    );

  }

}