import 'package:asset_mng/main_assets.dart';
import 'package:asset_mng/main_cash_flow.dart';
import 'package:asset_mng/main_search.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Widget currentPage = MainSearch();

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'My Asset Manager',
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Asset Manager'),
        ),
        body: Center(
          child: currentPage
        ),
        bottomNavigationBar: FancyBottomNavigation(
          tabs: [
            TabData(iconData: Icons.attach_money_rounded, title: 'Assets'),
            TabData(iconData: Icons.search, title: 'Search'),
          ],
          onTabChangedListener: (position) {
            setState(() {
              if(position == 0) {
                currentPage = MainAssets();
              } else if(position == 1) {
                currentPage = MainSearch();
              }
            });
          },
        ),
      ),
    );
  }
}
