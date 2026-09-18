import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/core/theme/app_colors.dart';

class MovieGenresChips extends StatelessWidget {

  List <String> genresList ;
  final Function (String)? onSelect;
  final String? selectedGenre;

  MovieGenresChips({
    required this.genresList,
    this.onSelect,
    this.selectedGenre
  });

  @override
  Widget build(BuildContext context) {

    if (genresList.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: genresList.map((genre){

        bool isSelected = (selectedGenre == genre);

        return ActionChip(
          //make chip smaller
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: EdgeInsets.zero,

          label: Text(genre),
          labelStyle: GoogleFonts.neuton(fontSize: 11,color: Colors.white) ,

          side: BorderSide.none,
          color: WidgetStateProperty.all(
            isSelected ? AppColors.darkGreen:AppColors.blueSky_ ,
          ),

          onPressed:(){
            if (onSelect != null) {
              onSelect!(genre);
            }
          }

        );

      }).toList()

    );

  }



}