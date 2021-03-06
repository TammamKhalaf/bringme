import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CrudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(collection, data) async {
    if (isLoggedIn()) {
      Firestore.instance.collection(collection).add(data).catchError((e) {
        print(e);
      });
    } else {
      print('il faut etre loggé pour ajouter des données');
    }
  }

  getData(collection) async {
    return await Firestore.instance.collection(collection).snapshots();
  }

  getDataDocuments(collection) async {
    return await Firestore.instance.collection(collection).getDocuments();
  }

  getDataFromUserFromDocument() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('user').document(user.uid).get();
  }

  getDataFromDeliveryManFromDocument() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('deliveryman').document(user.uid).get();
  }

  getDataFromUserFromDocumentWithID(userID) async{
    return await Firestore.instance.collection('user').document(userID).get();
  }

  getDataFromUserDemand(userID,demandID) async{
    return await Firestore.instance.collection('user').document(userID).collection('demand').document(demandID).get();
  }

  getAllDemandFromUser(userID) async{
    return await Firestore.instance.collection('user').document(userID).collection('demand').getDocuments();
  }

  updateDemandData(userID, demandID, demandDataMap) async{
    DocumentReference ref = Firestore.instance.collection('user').document(userID).collection('demand').document(demandID);
    return ref.setData(demandDataMap, merge: true);

  }

  getDataFromDeliveryManFromDocumentWithID(userID) async{
    return await Firestore.instance.collection('deliveryman').document(userID).get();
  }

  getDataFromClubFromDocumentWithID(clubID) async{
    return await Firestore.instance.collection('club').document(clubID).get();
  }

  getDataFromClubFromDocument() async{
    return await Firestore.instance.collection('club').getDocuments();
  }

  getDataFromUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance
        .collection('user')
        .document(user.uid)
        .snapshots();
  }

  getDataFromDeliveryMan() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance
        .collection('deliveryman')
        .document(user.uid)
        .snapshots();
  }


  updateData(collection, selectedDoc, newValues) {
    Firestore.instance
        .collection(collection)
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }


  createOrUpdateUserData(Map<String, dynamic> userDataMap) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    print('USERID ' + user.uid);
    DocumentReference ref = Firestore.instance.collection('user').document(user.uid);
    return ref.setData(userDataMap, merge: true);

  }

  updateUserDataWithUserID(userID, Map<String, dynamic> userDataMap) async{
    DocumentReference ref = Firestore.instance.collection('user').document(userID);
    return ref.setData(userDataMap, merge: true);

  }


  createOrUpdateDeliveryManData(Map<String, dynamic> deliveryManDataMap) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    print('USERID ' + user.uid);
    DocumentReference ref = Firestore.instance.collection('deliveryman').document(user.uid);
    return ref.setData(deliveryManDataMap, merge: true);

  }

  updateDeliveryManDataWithID(devivelryManID, Map<String, dynamic> deliveryManDataMap) async{
    DocumentReference ref = Firestore.instance.collection('deliveryman').document(devivelryManID);
    return ref.setData(deliveryManDataMap, merge: true);

  }

  getUserCourses() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('user').document(user.uid).collection('course').getDocuments();
  }

  getUserHistoric() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('user').document(user.uid).collection('historic').getDocuments();
  }

  getDeliveryManCourses() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('deliveryman').document(user.uid).collection('course').getDocuments();
  }

  getDeliveryManHistoric() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('deliveryman').document(user.uid).collection('historic').getDocuments();
  }

//  deleteData(collection, docId) {
//    Firestore.instance
//        .collection(collection)
//        .document(docId)
//        .delete()
//        .catchError((e) {
//      print(e);
//    });
//  }

}
