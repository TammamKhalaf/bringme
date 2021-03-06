import 'package:flutter/material.dart';
import 'package:bringme/authentification/auth.dart';
import 'package:bringme/login_signup_page.dart';
import 'package:bringme/services/crud.dart';
import 'package:bringme/delivery/home_page_delivery.dart';
import 'package:bringme/user/welcome_page.dart';


enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool pro;

  CrudMethods crudObj = new CrudMethods();

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
      });

      setState(() {
        crudObj.getDataFromUserFromDocument().then((value){
          print(value.data);
          if(value.data == null) {
            setState(() {
              pro = true;
            });
          }else{
            setState(() {
              pro = false;
            });
          }
        });
      });

      authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;

    });
  }

  void loginCallback() {
    print("EXEC LOGINCALLBACK");
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    //permet de simplifier la gestion de la connaissance du role de l'utilisateur
    //si on trouve des data dans la collection user alors c'est un user
    //sinon il s'agit d'un livreur
    //ensuite on root vers la bonne page
    //peut etre mieux de partir sur l'option avec le documentreference et choper la collection parent
    //pour savoir si il s'agit d'un livreur ou un user
    setState(() {
      crudObj.getDataFromUserFromDocument().then((value){
        print(value.data);
        print("EXEC INIT TO KNOW TYPE OF USER");
        if(value.data == null) {
          setState(() {
            pro = true;
            authStatus = AuthStatus.LOGGED_IN;
          });
        }else{
          setState(() {
            pro = false;
            authStatus = AuthStatus.LOGGED_IN;
          });
        }
      });
//      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    print("EXEC LOG OUT CALL BACK");
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null && pro == false) {
          return new WelcomePage(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        }
        else if(_userId.length > 0 && _userId != null && pro == true){
          return new HomePageDelivery(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        }
        else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}