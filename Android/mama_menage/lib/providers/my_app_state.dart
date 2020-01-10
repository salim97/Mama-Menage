import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mama_menage/models/model_facture.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/models/model_user.dart';

const DATABASE_PATH_users = "users";
const DATABASE_PATH_prdocuts = "products";
const DATABASE_PATH_factures = "factures";

const DEV_MODE = false;

class MyAppState extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseDatabase database;
  DatabaseReference databaseReferenceUsers, databaseReferenceProducts, databaseReferenceFactures;

  FirebaseUser _firebaseUser = null;
  get firebaseUser => _firebaseUser;
  set firebaseUser(FirebaseUser value) {
    _firebaseUser = value;
    notifyListeners();
  }

  List<ModelProduct> products = new List<ModelProduct>();
  List<ModelProduct> selectedProducts = new List<ModelProduct>();
  List<ModelFacture> factures = new List<ModelFacture>();
  ModelUser user ;

  get counterSelectedProducts {
    int tmp = 0;
    selectedProducts?.forEach((p) => p.checked ? tmp++ : tmp += 0);
    return tmp;
  }

  get totalCostSelectedProducts {
    double tmp = 0;
    selectedProducts?.forEach((p) => p.checked ? tmp += p.selectedQuantity * p.cost : tmp += 0);
    return tmp;
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
    } else {
      signInAnonymously();
    }
  }

  signInAnonymously() async {
    AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
    firebaseUser = authResult.user;
    database = new FirebaseDatabase();
    databaseReferenceUsers = database.reference().child(DATABASE_PATH_users);
    databaseReferenceUsers.onChildChanged.listen((event) {
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      //sensors = toSensorList(event.snapshot.value);
    });

    databaseReferenceProducts = database.reference().child(DATABASE_PATH_prdocuts);
    databaseReferenceProducts.onChildChanged.listen((event) {
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      //sensors = toSensorList(event.snapshot.value);
    });

    databaseReferenceFactures = database.reference().child(DATABASE_PATH_factures);
    databaseReferenceFactures.onChildChanged.listen((event) {
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
    });
    notifyListeners();
  }

  Future<List<ModelProduct>> mapToProducts(Map<dynamic, dynamic> mapResponse) async {
    products.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        products.add(ModelProduct.fromJson(value));
      }
    });
    for (int i = 0; i < products.length; i++) {
      // print(products.elementAt(i).imagePath);
      products.elementAt(i).imagePath = await loadImage(products.elementAt(i).imagePath);
      // print(products.elementAt(i).imagePath);
    }

    notifyListeners();
    return products;
  }

  Future<bool> login({String email, String password}) async {
    await signInAnonymously();
    DataSnapshot snapshot = await databaseReferenceUsers.once();
    print('Data : ${snapshot.value}');
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    List<ModelUser> users = new List<ModelUser>();
    mapResponse?.forEach((key, value) {
      if (key.toString().isNotEmpty) {
        users.add(ModelUser.fromJson(value));
      }
    });

    for(int i = 0 ; i < users.length ; i++ )
    {
        if (users.elementAt(i).name == email && users.elementAt(i).password == password) {
          user = users.elementAt(i) ;
          notifyListeners();
          return true;
        }
    }
    return false;
  }

  //EXTRA

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

  Future<dynamic> loadImage(String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }
}
