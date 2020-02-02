import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mama_menage_v3/models/model_client.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/models/model_user.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const DATABASE_PATH_users = "users";
const DATABASE_PATH_prdocuts = "products";
const DATABASE_PATH_commandes = "commandes";
const DATABASE_PATH_clients = "clients";
const DATABASE_PATH_admin_emails = "admin_emails";

const DEV_MODE = false;
const BLACK_IMAGE =
    "http://images.pexels.com/photos/998641/pexels-photo-998641.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260";

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

  //global
  List<ModelProduct> products = new List<ModelProduct>();
  List<ModelFacture> factures = new List<ModelFacture>();
  List<ModelClient> clients = new List<ModelClient>();
  List<String> admin_emails = new List<String>();

  //in use
  VoidCallback goNextTab ;
  ModelClient client = null;
  ModelUser user;
  List<ModelProduct> get selectedProducts => products.where((p) => p.selectedProduct).toList();

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
    loadSettings();
    if (DEV_MODE) {
      products = [
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: ["assets/images/clothes1.jpg"],
        ),
        ModelProduct(
          name: "B",
          cost: 50,
          imagePath: ["assets/images/clothes6.jpg"],
        ),
        ModelProduct(
          name: "C",
          cost: 300,
          imagePath: ["assets/images/clothes3.jpg"],
        ),
        ModelProduct(
          name: "D",
          cost: 200,
          imagePath: ["assets/images/clothes4.jpg"],
        ),
        ModelProduct(
          name: "E",
          cost: 100,
          imagePath: ["assets/images/clothes5.jpg"],
        ),
        ModelProduct(
          name: "Jacket",
          cost: 100,
          imagePath: ["assets/images/clothes7.jpg"],
        ),
      ];
      //selectedProducts = products;
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

    databaseReferenceFactures = database.reference().child(DATABASE_PATH_commandes);
    databaseReferenceFactures.onChildChanged.listen((event) {
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
    });
    notifyListeners();
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

    for (int i = 0; i < users.length; i++) {
      if (users.elementAt(i).name == email && users.elementAt(i).password == password) {
        user = users.elementAt(i);
        await getAllClients();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  signOut() {
    client = null;
    user = null;
    products.forEach((p) => p.selectedProduct = false);
    notifyListeners();
  }

  Future<List<ModelClient>> getAllClients() async {
    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_clients).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    clients.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        clients.add(ModelClient.fromJson(value));
      }
    });

    notifyListeners();
    return clients;
  }

  Future<List<ModelProduct>> getAllProducts() async {
    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_prdocuts).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    products.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        if (ModelProduct.fromJson(value) != null) products.add(ModelProduct.fromJson(value));
      }
    });
    for (int i = 0; i < products.length; i++) {
      // print(products.elementAt(i).imagePath);
      for (int j = 0; j < products.elementAt(i).imagePath.length; j++) {
        products[i].imagePath[j] = await loadImage(products[i].imagePath[j]);
      }

      // print(products.elementAt(i).imagePath);
    }

    notifyListeners();
    return products;
  }

  Future<List<String>> getAllEmails() async {
    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_admin_emails).once();
    List<dynamic> mapResponse = snapshot.value;
    admin_emails.clear();
    mapResponse?.forEach((value) async {
      admin_emails.add(value.toString());
    });

    notifyListeners();
    return admin_emails;
  }

  Future<bool> saveFatures() async {
    String createdAt = new DateTime.now().millisecondsSinceEpoch.toString();
    List<dynamic> array = new List<dynamic>();
    selectedProducts.forEach((p) => array.add(p.toJson()));
    await database.reference().child(DATABASE_PATH_commandes).child(createdAt).set({
      'createdAt': createdAt,
      'user': user.toJson(),
      'client': client.toJson(),
      'products': array,
    });
    return true;
    // databaseReference.child("2").set({
    //   'title': 'Flutter in Action',
    //   'description': 'Complete Programming Guide to learn Flutter'
    // });
  }

  //EXTRA
  void flushbar({context, title, message, color = Colors.green}) {
    if (context == null) return;
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
    // StorageReference sr = await FirebaseStorage.instance.ref().child(image) ;
    // if(sr == null ) return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC" ;
    try {
      return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
    } on PlatformException catch (e) {
      // throw e.code;
      print(e.code);
      return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
    } catch (e) {
      print(e);
      return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
    }
  }

  int landscape_count = 4;
  int portrait_count = 3;
  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    landscape_count = (prefs.getInt('landscape_count') ?? 4);
    portrait_count = (prefs.getInt('portrait_count') ?? 3);
  }

  saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('landscape_count', landscape_count);
    prefs.setInt('portrait_count', portrait_count);
  }
}

List<Color> myTheme = [Color.fromRGBO(104, 193, 139, 1.0), Color.fromRGBO(57, 178, 186, 1.0)];

Gradient myGradient = LinearGradient(colors: myTheme);
