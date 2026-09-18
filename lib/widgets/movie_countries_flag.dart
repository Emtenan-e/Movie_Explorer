import 'package:flutter/cupertino.dart';
import 'package:country_flags/country_flags.dart';


class MovieContriesFlag extends StatelessWidget {

  List <String> countries ;

  MovieContriesFlag ({
    required this.countries
  });

  @override
  Widget build(BuildContext context) {

    return Wrap(
      spacing: 5.0,
      children: countries.map((country){
        return CountryFlag.fromCountryCode(
          country,
          theme: const ImageTheme(
            width: 10, height: 10,
            shape:RoundedRectangle(2),
          ),
        );

      }).toList()
    );

  }



}