const functions = require('firebase-functions');
const admin = require('firebase-admin');
var moment = require('moment');
admin.initializeApp();




exports.notifNewDelivery = functions.firestore.document('request/{requestId}').onCreate((snap, context) => {

    //permet d'afficher dans la console cloud functions les données qui ont été créées pour trigger la fonction
    const newRequest = snap.data();
    //const t = newRequest.test;
    //console.log(newRequest);
    //console.log(t);

    console.log(moment(newRequest.deliveryDate));

    //trop chiant d'avoir l'heure avec un unix timestamp et moment js
    //let hour = moment(newRequest.deliveryDate).format("hh:mm");
    let date = moment(newRequest.deliveryDate).format("DD/MM/YY");


    const payload = {
        notification: { title: 'Nouvelle demande de livraison !', body: 'Le ' + date + ' à destination de ' + newRequest.destination, badge: '1', sound: 'default', }
    };

    //permet de stocker les tokens de notif de tout les delivery man pour pouvoir envoyer les notifs a tout ceux qui en ont un
    let tokens = []

    return admin.firestore().collection('deliveryman').get().then(doc => {
           doc.forEach(docu => {
                if(docu.data().tokenNotif === undefined){
                    //ne rien faire si il n'y a pas de token
                }else{
                    tokens.push(docu.data().tokenNotif);
                }
            });
        console.log(tokens);
        return tokens;
    }).then((tokens) => {
        return admin.messaging().sendToDevice(tokens, payload);
    });
});
