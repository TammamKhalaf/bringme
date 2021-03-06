import 'package:flutter/material.dart';
import 'package:bringme/authentification/auth.dart';
import 'package:bringme/services/crud.dart';
import 'package:bringme/services/userData.dart';
import 'package:bringme/services/deliveryManData.dart';
import 'primary_button.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

enum FormType { login, register, registerAsPro }

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  CrudMethods crudObj = new CrudMethods();
  String _pageTitle = "Connexion";

  String _email;
  String _password;
  String _name;
  String _surname;
  String _phone;

  //livreur
  String _typeOfRemorque = 'Véhicule particuliers';
  String _immatriculation;
  String _marque;

  String _errorMessage;
  final _resetEmailformKey = new GlobalKey<FormState>();
  String _emailReset;

  FormType _formType = FormType.login;

  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.createUser(_email, _password);
        setState(() {
          _isLoading = false;
        });

//        if (userId.length > 0 && userId != null) {
//          widget.loginCallback();
//        }

        if (_formType == FormType.register) {
          UserData userData = new UserData(
            name: _name,
            surname: _surname,
            mail: _email,
            phone: _phone,
            picture:
                "https://firebasestorage.googleapis.com/v0/b/bring-me-b2e30.appspot.com/o/awid500.png?alt=media&token=36063bf4-f2d4-4ed4-9e86-5cd89e51b4f7",
          );

          crudObj.createOrUpdateUserData(userData.getDataMap());
        }

        if (_formType == FormType.registerAsPro) {
          DeliveryManData deliveryManData = new DeliveryManData(
            name: _name,
            surname: _surname,
            mail: _email,
            phone: _phone,
            typeOfRemorque: _typeOfRemorque,
            immatriculation: _immatriculation,
            marque: _marque,
            picture:
                "https://firebasestorage.googleapis.com/v0/b/bring-me-b2e30.appspot.com/o/awid_livreur500.png?alt=media&token=661d3d63-254b-45cb-9b79-d84544d6bb5b",
          );

          crudObj.createOrUpdateDeliveryManData(deliveryManData.getDataMap());
        }

        if (userId == null) {
          print("EMAIL PAS VERIFIE");
          setState(() {
            _errorMessage = 'Vérifiez votre e-mail 🙂';
            _isLoading = false;
            _formType = FormType.login;
          });
        } else {
          _isLoading = false;
          widget.loginCallback();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          switch (e.code) {
            case 'ERROR_INVALID_EMAIL':
              _errorMessage = 'Email invalide';
              break;
            case 'ERROR_USER_NOT_FOUND':
              _errorMessage = 'Aucun utilisateur trouvé ';
              break;
            case 'ERROR_WRONG_PASSWORD':
              _errorMessage = 'Mauvais mot de passe';
              break;
            default:
              _errorMessage = 'Erreur de connexion';
              break;
          }
        });
        print(e);
      }
    } else {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _formType = FormType.login;
    super.initState();
  }

  void moveToRegister() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _pageTitle = "Inscription";
      _errorMessage = '';
    });
  }

  void moveToRegisterAsPro() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.registerAsPro;
      _pageTitle = "Inscription Pro";
      _errorMessage = '';
    });
  }

  void moveToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _pageTitle = "Connexion";
      _errorMessage = '';
    });
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('email'),
        decoration: InputDecoration(
          labelText: 'Email',
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Saisissez un e-mail valide';
          }
          return null;
        },
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('namefield'),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Prénom',
          icon: new Icon(
            Icons.perm_identity,
            color: Colors.grey,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Saisissez un prénom';
          }
          return null;
        },
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget _buildSurnameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('surnamefield'),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nom',
          icon: new Icon(
            Icons.perm_identity,
            color: Colors.grey,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Saisissez un nom';
          }
          return null;
        },
        onSaved: (value) => _surname = value.trim(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('password'),
        decoration: InputDecoration(
            labelText: 'Mot de passe',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        controller: _passwordTextController,
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return '6 caractères minimum sont requis';
          }
          return null;
        },
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _builConfirmPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Confirmez le mot de passe',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        obscureText: true,
        validator: (String value) {
          if (_passwordTextController.text != value) {
            return 'Le mot de passe ne correspond pas';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        maxLines: 1,
        key: new Key('phonefield'),
        decoration: InputDecoration(
          labelText: 'Téléphone',
          icon: new Icon(
            Icons.phone,
            color: Colors.grey,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'numéro invalide';
          }
          return null;
        },
        onSaved: (value) => _phone = value.trim(),
      ),
    );
  }

  Widget _buildTypeOfRemorqueField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.airport_shuttle,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 15,
          ),
          DropdownButton<String>(
            value: _typeOfRemorque,
            icon: Icon(Icons.arrow_downward),
            iconSize: 17,
            elevation: 16,
            style: TextStyle(color: Colors.grey[600]),
            underline: Container(
              height: 1,
              color: Colors.grey[500],
            ),
            onChanged: (String newValue) {
              setState(() {
                _typeOfRemorque = newValue;
              });
            },
            items: <String>[
              'Véhicule particuliers',
              'Utilitaire petit',
              'Utilitaire moyen',
              'Utilitaire grand',
              'Véhicule Isotherme ou Frigorifique',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImmatriculationField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('immatriculationfield'),
        decoration: InputDecoration(
          labelText: 'Immatriculation',
          icon: new Icon(
            Icons.assignment,
            color: Colors.grey,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Immatriculation invalide';
          }
          return null;
        },
        onSaved: (value) => _immatriculation = value.trim(),
      ),
    );
  }

  Widget _buildMarqueField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('marqueField'),
        decoration: InputDecoration(
          labelText: 'Marque du véhicule',
          icon: new Icon(
            Icons.drive_eta,
            color: Colors.grey,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Renseignez une marque';
          }
          return null;
        },
        onSaved: (value) => _marque = value.trim(),
      ),
    );
  }

  Widget submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            PrimaryButton(
              key: new Key('login'),
              text: 'Connexion',
              height: 44.0,
              onPressed: validateAndSubmit,
            ),
            FlatButton(
                key: new Key('need-account'),
                child: Text("Créer un compte"),
                onPressed: moveToRegister),
          ],
        );
      default:
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            PrimaryButton(
                key: new Key('register'),
                text: 'Créer',
                height: 44.0,
                onPressed: validateAndSubmit),
            FlatButton(
                key: new Key('need-login'),
                child: Text("Déjà un compte ? Se connecter"),
                onPressed: moveToLogin),
          ],
        );
    }
  }

  Widget _showCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget comptePro() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        onPressed: moveToRegisterAsPro,
        child: Text('Créer un compte Pro'),
      ),
    );
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content:
//              new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showResetPassword() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        onPressed: _dialogResetPassword,
        child: Text('Mot de passe oublié ?', style: TextStyle(color: Colors.grey[600]),),
      ),
    );
  }


  bool validateAndSaveReset() {
    final form = _resetEmailformKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget _buildEmailResetField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('emailreset'),
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Saisissez un e-mail valide';
          }
          return null;
        },
          onSaved: (value) => _emailReset = value.trim(),
      ),
    );
  }

  _dialogResetPassword(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: Text("Nous allons vous envoyer un mail pour réinitialiser votre mot de passe"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Form(
                    key: _resetEmailformKey,
                    child: _buildEmailResetField(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Fermer", style: TextStyle(color: Colors.black),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Envoyer l'e-mail", style: TextStyle(color: Colors.green[400]),),
                onPressed: () {
                  if(validateAndSaveReset()){
                    widget.auth.resetPassword(_emailReset);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });

  }


  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Le mail ne peut pas être vide' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _buildForm() {
    return new Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _showLogo(),
          _buildEmailField(),
          _formType == FormType.register ? _buildNameField() : Container(),
          _formType == FormType.registerAsPro ? _buildNameField() : Container(),
          _formType == FormType.register ? _buildSurnameField() : Container(),
          _formType == FormType.registerAsPro
              ? _buildSurnameField()
              : Container(),
          _formType == FormType.register ? _buildPhoneField() : Container(),
          _formType == FormType.registerAsPro
              ? _buildPhoneField()
              : Container(),
          _formType == FormType.registerAsPro
              ? _buildTypeOfRemorqueField()
              : Container(),
          _formType == FormType.registerAsPro
              ? _buildImmatriculationField()
              : Container(),
          _formType == FormType.registerAsPro
              ? _buildMarqueField()
              : Container(),
          _buildPasswordField(),
          _formType == FormType.register
              ? _builConfirmPasswordTextField()
              : Container(),
          _formType == FormType.registerAsPro
              ? _builConfirmPasswordTextField()
              : Container(),
          _isLoading == false ? submitWidgets() : _showCircularProgress(),
          showErrorMessage(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 68.0,
        child: Image.asset('assets/AWID1080_trait.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double font = MediaQuery.of(context).textScaleFactor;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('AWID'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _pageTitle,
                    style: TextStyle(fontSize: 25 * font),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildForm(),
                    ),
                  ],
                ),
                _formType == FormType.registerAsPro ? Container() : comptePro(),
                showResetPassword(),
              ],
            ),
          ),
        ));
  }
}
