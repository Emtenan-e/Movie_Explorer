import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_explorer/screens/search_page.dart';
import 'package:movie_explorer/screens/watch_list_page.dart';

import '../core/theme/app_colors.dart';
import 'explore_page.dart';

class Homepage extends StatefulWidget{
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  int _selectedIndex = 0;

  final ValueNotifier<int> _scrollNotifier = ValueNotifier<int>(0);

  late final List<Widget> _widgetOption;

  final GlobalKey<NavigatorState> _exploreNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _watchListNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>();


  @override
  void initState() {
    super.initState();

    _widgetOption = <Widget> [
      Navigator(
        key: _exploreNavigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) =>  ExplorePage(scrollNotifier: _scrollNotifier),
        ),
      ),

      Navigator(
        key: _watchListNavigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => WatchListPage(),
        ),
      ),

      Navigator(
        key: _searchNavigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => SearchPage(),
        ),
      ),

    ];

  }

  void _onItemTapped(int index) {

    if (index == 0 && _selectedIndex == 0) {
      if (_exploreNavigatorKey.currentState!.canPop()) {
        // return to all opened pages and explore page
        _exploreNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      }else{
        //upload page
        _scrollNotifier.value++;
      }
    } else if (index == 1 && _selectedIndex == 1)  {

      if (_watchListNavigatorKey.currentState!.canPop()) {
        // return to watchList page
        _watchListNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      }

    }else if (index ==2 && _selectedIndex ==2){
      _searchNavigatorKey.currentState!.popUntil((route)=>route.isFirst);
    }else{

      if (_selectedIndex == 0) {
        _exploreNavigatorKey.currentState!
            .popUntil((route) => route.isFirst);
      }

      setState(() {
        _selectedIndex = index;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Color(0xff18121e),
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOption,
        ),
        bottomNavigationBar: SizedBox(
          height: 48,
          child: BottomNavigationBar(
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset( 'assets/icons/movie_film.svg',
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),              ),
                activeIcon: SvgPicture.asset(
                  'assets/icons/movie_film.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.blueSky_, BlendMode.srcIn),
                ),
                label: 'Explore',
              ),

              BottomNavigationBarItem(
                  icon: SvgPicture.asset( 'assets/icons/bookmark.svg',
                    width: 15,
                    height: 15,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),              ),
                  activeIcon: SvgPicture.asset(
                    'assets/icons/bookmark.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(AppColors.blueSky_, BlendMode.srcIn),
                  ),
                  label: 'Watch list'),

              BottomNavigationBarItem(
                  icon: Icon(Icons.search,size: 17,),
                  activeIcon: Icon(Icons.search,size: 19,),
                  label: 'Genres')
            ],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.blueSky_,
            selectedLabelStyle:  GoogleFonts.neuton(fontSize: 12,color: AppColors.blueSky_),
            unselectedLabelStyle: const TextStyle(fontSize: 0),
            onTap: _onItemTapped,
            backgroundColor: AppColors.backgroundLight,
            unselectedItemColor:Colors.white,
          ),
        ),
      ),
    );

  }
}