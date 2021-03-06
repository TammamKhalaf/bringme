import 'package:flutter/material.dart';
import 'package:bringme/services/crud.dart';
import 'package:bringme/services/requestData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bringme/primary_button.dart';
import 'myDrawer.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//ce fichier s'appel home_page et la class HomePage mais devrait etre renommé en book_page (page "reserver")

class HomePage extends StatefulWidget {
  HomePage({Key key, this.userId}) : super(key: key);

  final String userId;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {

  static final formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CrudMethods crudObj = new CrudMethods();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _isLoading = false;

  static DateTime actualDate = DateTime.now();

  String _depart;
  String _destination;
  DateTime _retraitDate = actualDate;
  DateTime _deliveryDate = actualDate;
  String _description;
  String _object;

  Color dateColor = Colors.grey[700];
  Color marchandiseColor = Colors.grey[500];
  Color remorqueColor = Colors.grey[500];




  //retourne le token notif du user /!\ attention si un compte delivery et user son connecté au meme appareil il est possible que le token soit le meme
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) {
      print(token);
      crudObj.createOrUpdateUserData({"tokenNotif": token});
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        print(notification);
        print(notification['title']);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
    );

    //juste pour IOS
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }




  //type de remorque
  Map<String, dynamic> mapRemorque = {
    'Véhicule particuliers': false,
    'Utilitaire petit': false,
    'Utilitaire moyen': false,
    'Utilitaire grand': false,
    'Véhicule Isotherme ou Frigorifique': false,
  };

  //type de marchandise
  Map<String, dynamic> mapMarchandise = {
    'fragile': false,
    'leger': false,
    'lourd': false,
    'dangereux': false,
  };

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      formKey.currentState.reset();
      setState(() {
        _isLoading = true;
      });

      RequestData requestData = new RequestData(
        depart: _depart,
        destination: _destination,
        retraitDate: _retraitDate,
        deliveryDate: _deliveryDate,
        typeOfMarchandise: mapMarchandise,
        typeOfRemorque: mapRemorque,
        userId: widget.userId,
        completed: false,
        accepted: false,
        proposition: [],
        description: _description,
        object: _object,
      );

      DocumentReference docRef = await Firestore.instance
          .collection('request')
          .add(requestData.getDataMap());

      Firestore.instance
          .collection('user')
          .document(widget.userId)
          .collection('demand')
          .document(docRef.documentID)
          .setData(requestData.getDataMapForDemand());

      setState(() {
        _isLoading = false;
      });

      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Votre demande a été posté !')));
    } else {
      print("forme de demande non valide");
    }
  }


  bool validateMarchandise(){
    for(var v in mapMarchandise.values){
      if(v) return true;
    }
    return false;
  }


  bool validateRemorque(){
    for(var v in mapRemorque.values){
      if(v) return true;
    }
    return false;
  }


  Widget submitWidget() {
    return PrimaryButton(
      key: new Key('submitrequest'),
      text: 'Poster la demande',
      height: 44.0,
      onPressed: (){
        if(_deliveryDate.isBefore(_retraitDate) || _deliveryDate.isAtSameMomentAs(_retraitDate)){
          validateAndSave();
          setState(() {
            dateColor = Colors.red[400];
          });
        }else if(validateMarchandise() == false){
          validateAndSave();
          setState(() {
            marchandiseColor = Colors.red[400];
          });

        }else if(validateRemorque() == false){
          validateAndSave();
          setState(() {
            remorqueColor = Colors.red[400];
          });

        }else{
          validateAndSubmit();
        }
      },
    );
  }

  Widget demandObject() {
    return ListTile(
      title: Text(
        "Objet de la demande",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: TextFormField(
        maxLength: 30,
        textCapitalization: TextCapitalization.sentences,
        key: new Key('object'),
        decoration: InputDecoration(
          labelText: 'saisissez un objet',
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Vous devez saisir un objet';
          }
          return null;
        },
        onSaved: (value) => _object = value,
      ),
    );
  }

  Widget _selectDeparture() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 20.0, 10.0, 0.0),
      child: TextFormField(
        key: new Key('selectDepart'),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'selectionnez l\'adresse de départ',
          icon: new Icon(
            Icons.arrow_forward_ios,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Saisissez une adresse';
          }
          return null;
        },
        onSaved: (value) => _depart = value,
      ),
    );
  }

  Widget _selectDestination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 20.0, 10.0, 0.0),
      child: TextFormField(
        key: new Key('selectDestination'),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'selectionnez l\'adresse de destination',
          icon: new Icon(
            Icons.arrow_forward_ios,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Saisissez une adresse';
          }
          return null;
        },
        onSaved: (value) => _destination = value,
      ),
    );
  }

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Widget _selectRetraitDate(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Text(
            dateFormat.format(_retraitDate),
            style: TextStyle(color: Colors.grey[700]),
          ),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final selectedDate = await _selectDateTime(context);
            if (selectedDate == null) return;

            final selectedTime = await _selectTime(context);
            if (selectedTime == null) return;
            print(selectedTime);

            setState(() {
              this._retraitDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _selectDeliveryDate(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Text(
            dateFormat.format(_deliveryDate),
            style: TextStyle(color: dateColor),
          ),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final selectedDate = await _selectDateForDelivery(context);
            if (selectedDate == null) return;

            final selectedTime = await _selectTime(context);
            if (selectedTime == null) return;

            setState(() {
              this._deliveryDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              dateColor = Colors.grey[700];
            });
          },
        ),
      ],
    );
  }

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),

    );
  }

  Future<DateTime> _selectDateTime(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(seconds: 1)),
      locale: Locale("fr", "FR"),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  Future<DateTime> _selectDateForDelivery(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: _retraitDate,
      locale: Locale("fr", "FR"),
      firstDate: _retraitDate,
      lastDate: DateTime(2100),
    );
  }

  Widget _selectRetraitTime() {
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Text(
            "selectionnez le jour et l\'heure de retrait",
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(
            height: 10.0,
          ),
          _selectRetraitDate(context),
        ],
      ),
    );
  }

  Widget _selectDeliveryTime() {
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Text(
            "selectionnez le jour et l\'heure de livraison",
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(
            height: 10.0,
          ),
          _selectDeliveryDate(context),
        ],
      ),
    );
  }

  Widget _showSelectTypeOfMarchandise() {
    return RaisedButton(
      color: marchandiseColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: mapMarchandise['fragile'],
                            onChanged: (bool value) {
                              setState(() {
                                mapMarchandise['fragile'] = value;
                              });
                            },
                          ),
                          Text("Fragile"),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: mapMarchandise['leger'],
                            onChanged: (bool value) {
                              setState(() {
                                mapMarchandise['leger'] = value;
                              });
                            },
                          ),
                          Text("Léger"),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: mapMarchandise['lourd'],
                            onChanged: (bool value) {
                              setState(() {
                                mapMarchandise['lourd'] = value;
                              });
                            },
                          ),
                          Text("Lourd"),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: mapMarchandise['dangereux'],
                            onChanged: (bool value) {
                              setState(() {
                                mapMarchandise['dangereux'] = value;
                              });
                            },
                          ),
                          Text("Dangereux"),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          child: Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  );
                }),
              );
            });
        setState(() {
          marchandiseColor = Colors.grey[500];
        });
      },
    );
  }

  Widget _showSelectTypeOfRemorque() {
    return RaisedButton(
      color: remorqueColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: mapRemorque['Véhicule particuliers'],
                              onChanged: (bool value) {
                                setState(() {
                                  mapRemorque['Véhicule particuliers'] = value;
                                });
                              },
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Véhicule particuliers",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: mapRemorque['Utilitaire petit'],
                              onChanged: (bool value) {
                                setState(() {
                                  mapRemorque['Utilitaire petit'] = value;
                                });
                              },
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Utilitaire petit",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: mapRemorque['Utilitaire moyen'],
                              onChanged: (bool value) {
                                setState(() {
                                  mapRemorque['Utilitaire moyen'] = value;
                                });
                              },
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Utilitaire moyen",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: mapRemorque['Utilitaire grand'],
                              onChanged: (bool value) {
                                setState(() {
                                  mapRemorque['Utilitaire grand'] = value;
                                });
                              },
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Utilitaire grand",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: mapRemorque['Véhicule Isotherme ou Frigorifique'],
                              onChanged: (bool value) {
                                setState(() {
                                  mapRemorque['Véhicule Isotherme ou Frigorifique'] = value;
                                });
                              },
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Véhicule Isotherme ou Frigorifique",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            child: Text(
                              "Ok",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
            });
        setState(() {
          remorqueColor = Colors.grey[500];
        });
      },
    );
  }

  Widget _enterDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 20.0, 10.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        key: new Key('enterDescription'),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Ajouter une description',
          icon: new Icon(
            Icons.description,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onSaved: (value) => _description = value,
      ),
    );
  }

  Widget _showTypeOfMarchandise() {
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Text(
            "selectionnez le type de marchandise",
            style: TextStyle(color: Colors.grey[700]),
          ),
          _showSelectTypeOfMarchandise(),
        ],
      ),
    );
  }

  Widget _showTypeOfRemorque() {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Text(
            'Selectionnez le type de remorque',
            style: TextStyle(color: Colors.grey[700]),
          ),
          _showSelectTypeOfRemorque(),
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                demandObject(),
                _selectDeparture(),
                _selectDestination(),
                _selectRetraitTime(),
                _selectDeliveryTime(),
                _showTypeOfMarchandise(),
                _showTypeOfRemorque(),
                _enterDescription(),
              ],
            ),
          ),
          _isLoading == false ? submitWidget() : _showCircularProgress(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double font = MediaQuery.of(context).textScaleFactor;
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Reserver"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16.0),
                child: buildForm(),
              ),
            ]),
          ]),
        ),
      ),
      drawer: MyDrawer(
        currentPage: "reserver",
        userId: widget.userId,
      ),
    );
  }
}
