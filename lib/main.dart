import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer/screens/homepage.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
void main() async{

  //allow async code
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('myMoviesBox');

  //allow only vertical view
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MovieApp());
  });


}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.blueSky_,
          ),
      ),

      title: 'Movie Explorer',

      builder: (context, child) {
        return MediaQuery(
          //don't scale text size.
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),child: child!,

        );
      },

      home: Homepage(),
    );
  }
}


