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
  VoidCallback goNextTab;
  ModelClient client = null;
  ModelUser user;
  ModelFacture currentFacture = null;
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
      //signInAnonymously();
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

  Future<List<ModelFacture>> getAllCommandes() async {
    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_commandes).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    factures.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        factures.add(ModelFacture.fromJson(value));
      }
    });

    notifyListeners();
    return factures;
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
    await database.reference().child(DATABASE_PATH_commandes).child(createdAt).set(
        {'createdAt': createdAt, 'user': user.toJson(), 'client': client.toJson(), 'products': array, 'valid': false});
    await getAllCommandes();
    factures.forEach((f) {
      if (f.createdAt == createdAt) currentFacture = f;
    });
    notifyListeners();
    return true;
    // databaseReference.child("2").set({
    //   'title': 'Flutter in Action',
    //   'description': 'Complete Programming Guide to learn Flutter'
    // });
  }
  String currentFactureToHTML() 
  {
    String tableBody = ""; 
        int total = 0;
        
    for (int i = 0; i < currentFacture.products.length; i++) {
      tableBody += " <tr>" ;
       tableBody += " <td style=\"width: 5%\"><b> "+(i+1).toString()+"<br></b></td>" ;
       tableBody += " <td style=\"width: 50%\"><b> "+currentFacture.products.elementAt(i).name+"<br></b></td>" ;
       tableBody += " <td style=\"width: 10%\"><b> "+currentFacture.products.elementAt(i).selectedQP.toString()+"<br></b></td>" ;
       tableBody += " <td style=\"width: 10%\"><b> "+currentFacture.products.elementAt(i).quantity.toString()+"<br></b></td>" ;
       tableBody += " <td style=\"width: 10%\"><b> "+currentFacture.products.elementAt(i).cost.toString()+"<br></b></td>" ;
       tableBody += " <td style=\"width: 10%\"><b> 19.00<br></b></td>" ;
       tableBody += " <td style=\"width: 10%\"><b> "+currentFacture.products.elementAt(i).total.toString()+"<br></b></td>" ;
      tableBody += " </tr>" ;
      total += currentFacture.products.elementAt(i).total;
    }

//first page 20 max




    String clientBody = "";
    clientBody += "<p><b>Client: "+currentFacture.client.name+"</b></p>";
    clientBody += "<p>Adresse: "+currentFacture.client.name+"</p>";
    
    clientBody += "<pre>N RC: ####### &#9;| N FISCALE: #######</pre>";
    clientBody += "<pre>N ART: ####### </pre>";

                
              int pageCount = 1 ;  
                
    String htmlContent =
"""
<!DOCTYPE html>
<html>

<head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type">
    <title>Facture</title>
     <link rel="stylesheet" href="style_moz.css">
    <style>
        #body {
        background: rgb(204, 204, 204);
        }
        table {
        border-collapse: collapse;
        }
        table,
        th,
        td {
        border: 2px solid #888888;
        }
        p {
        margin: 0
        }
        .bigTable {
        border-collapse: collapse;
        width: 100%;
        }
        tr:nth-child(odd) {
        background-color: #f2f2f2
        }
        th {
        background-color: #d4d4d4;
        height: 35px;
        color: black;
        }
        page[size="A4"] {
        background: white;
        width: 21cm;
        height: """+(29.7 * pageCount ).toString() +"""cm;
        display: block;
        padding: 1cm;
        position: relative;
        }
        @media print {
        body,
        page[size="A4"] {
        margin: 0;
        box-shadow: 0;
        }
        }
    </style>
</head>

<body>
    <page size="A4">
        <div>
            <h3>Mama Menage</h3>
            <p>COP IMO EL BAHDJA N 02 REGHAIA</p>
            <p>ALGER</p>
        </div>
        <div style="margin-top: 0.5cm;" id="infoTable">
            <div style="float: left;">
                <p>N RC :      06/00-5112684 A16</p>
                <p>N FISCALE : 178160601093118</p>
                <p>N ART :     16430745011</p>
            </div>
            <div style="float: right; border:2px solid black; padding: 5px; padding-bottom:0px; border-radius: 10px">
              """+clientBody+"""
            </div>
        </div>
        </hr>
        <h1 style="margin-top: 1cm; padding-top: 0.2cm; clear: both;">Facture</h1>
        <table style="margin-top: 0.5cm; width: 400px; height: 50px;">
            <tbody>
                <tr>
                    <th style="text-align:left;width:37.0mm;">
                        <b>Numero du Facture</b>
                    </th>
                    <th style="text-align:left;width:40.0mm;">
                        <b>Date</b>
                    </th>
                </tr>
                <tr>
                    <td>
                        <center>{{factureNbr}}</center>
                    </td>
                    <td>
                        <center>{{factureDate}}</center>
                    </td>
                </tr>
            </tbody>
        </table>
        <table class="bigTable" style="margin-top: 0.5cm;" border="1">
            <tbody>
                <tr>
                    <th style="width: 5%"><b> N°<br></b></th>
                    <th style="width: 50%"><b>Designtion<br></b></th>
                    <th style="width: 5%"><b>Q.P<br></b></th>
                    <th style="width: 5%"><b>QUANTITE<br></b></th>
                    <th style="width: 15%"><b>Prix HT<br></b></th>
                    <th style="width: 5%"><b>TV(%)<br></b></th>
                    <th style="width: 15%"><b>Total HT<br></b></th>
                </tr>
""" + tableBody +"""
            </tbody>
        </table>
        <div style="position: absolute; bottom: """+(19 - currentFacture.products.length).toString()+"""cm; left: 1cm;word-wrap: break-word;width: 50%;">
            <p>Cette facture est arretee au montant :</p>
            <p><b>{{totalLetters}}</b></p>
            <p>Mode de paiment : <b>{{paimentMode}}</b></p>
        </div>
        <table style="position: absolute; bottom: """+(15 - currentFacture.products.length).toString()+"""cm; right: 1cm; border-collapse: collapse;border: 1px solid black; background-color: #f2f2f2">
            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>HORS TAXE (DA): </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p>"""+total.toString()+ """ DZD</p>
                </td>
            </tr>
            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>REMISE (DA) (0.00%): </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p> 0.00</p>
                </td>
            </tr>

            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>MONTAN, HORS TAXE (DA) : </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p> 0</p>
                </td>
            </tr>

            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>T.V.A (DA) : </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p> """ + (total * 0.19).toString() +"""</p>
                </td>
            </tr>

            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>TIMBRE (DA) : </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p> 26</p>
                </td>
            </tr>

            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b class="T3">R.T.A (DA):</b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p>0.00</p>
                </td>
            </tr>

            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>MONTANT T.T.C (DA): </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p>"""+(26 + total * 1.19).toString()+ """ DZD</p>
                </td>
            </tr>
        </table>
    </page>
</body>

</html>

""";


return htmlContent; 
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
