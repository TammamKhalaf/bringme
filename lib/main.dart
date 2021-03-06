import 'package:flutter/material.dart';
import 'package:bringme/root_page.dart';
import 'package:bringme/authentification/auth.dart';
import 'package:bringme/user/userProposition.dart';
import 'package:provider/provider.dart';
import 'package:bringme/user/userCourses.dart';
import 'package:bringme/delivery/deliveryCourses.dart';
import 'package:flutter/services.dart';
import 'package:bringme/delivery/historicPage.dart';
import 'package:bringme/user/userHistoric.dart';
import 'package:bringme/delivery/aProposDelivery.dart';
import 'package:bringme/user/aProposUser.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



void main() => runApp(new MyApp());



class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}


class _MyAppState extends State<MyApp>{

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('fr',"FR")
        ],
        debugShowCheckedModeBanner: false,
          title: 'AWID beta 0.1',
          theme: new ThemeData(
            primaryColor: Colors.black,
            accentColor: Colors.blueGrey
          ),
          routes:{
            '/': (BuildContext context) => new RootPage(auth: new Auth()),
            '/userProposition': (BuildContext context) => UserProposition(),
            '/userCourses': (BuildContext context) => UserCourses(),
            '/userHistoric': (BuildContext context) => UserHistoricPage(),
            '/aProposUser': (BuildContext context) => AProposUser(),
            '/deliveryCourses': (BuildContext context) => DeliveryCourses(),
            '/deliveryHistoric': (BuildContext context) => HistoricPage(),
            '/aProposDelivery': (BuildContext context) => AProposDelivery(),
          },
      ),
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<DrawerStateInfo>(
            builder: (_) => DrawerStateInfo()),
      ],
    );

  }
}

class DrawerStateInfo with ChangeNotifier {
  int _currentDrawer = 0;
  int get getCurrentDrawer => _currentDrawer;

  void setCurrentDrawer(int drawer) {
    _currentDrawer = drawer;
    notifyListeners();
  }

  void increment() {
    notifyListeners();
  }
}