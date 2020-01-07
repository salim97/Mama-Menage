import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mama_menage/models/model_product.dart';

const DATABASE_PATH_users = "users";
const DEV_MODE = true;

class MyAppState extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseDatabase database;
  DatabaseReference databaseReferenceUsers;

  FirebaseUser _firebaseUser = null;
  get firebaseUser => _firebaseUser;
  set firebaseUser(FirebaseUser value) {
    _firebaseUser = value;
    notifyListeners();
  }

   
  List<ModelProduct> products;
  List<ModelProduct> selectedProducts = new List<ModelProduct>();
  get counterSelectedProducts{
    int tmp = 0 ;
    selectedProducts?.forEach( (p) => p.checked ? tmp++ : tmp += 0 ) ;
    return tmp ;
  } 
  get totalCostSelectedProducts{
    double tmp = 0 ;
    selectedProducts?.forEach( (p) => p.checked ? tmp += p.quantity * p.cost : tmp += 0 ) ;
    return tmp ;
  } 
  MyAppState() {
    if (DEV_MODE) {
      products = [
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes1.jpg",
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes6.jpg",
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes3.jpg",
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes4.jpg",
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes5.jpg",
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: "assets/images/clothes7.jpg",
        ),
      ];
      selectedProducts = products;
    }
  }

  signInAnonymously() async {
    print('Data : ');
    AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
    firebaseUser = authResult.user;
    database = new FirebaseDatabase();
    databaseReferenceUsers = database.reference().child(DATABASE_PATH_users);
    databaseReferenceUsers.onChildChanged.listen((event) {
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      //sensors = toSensorList(event.snapshot.value);
    });
  }

  void flushbar({context, title, message, color = Colors.green}) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: title,
      message: message,
      icon: Icon(
        Icons.check_circle,
        size: 28.0,
        color: color,
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: color,
    )..show(context);
  }
}
