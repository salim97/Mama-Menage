import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mama_menage_v3/models/model_client.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/models/model_user.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  int current_index_carousel_products = 0;
  List<ModelProduct> products = new List<ModelProduct>();
  List<ModelFacture> factures = new List<ModelFacture>();
  List<ModelFacture> toSYNC_factures = new List<ModelFacture>();
  List<ModelClient> clients = new List<ModelClient>();
  List<String> admin_emails = new List<String>();
  ConnectivityResult internet;
  //in use
  VoidCallback goNextTab;
  ModelClient client = null;
  ModelUser user;
  ModelFacture currentFacture = null;
  ModelFacture tmp_currentFacture = null;
  List<ModelProduct> get selectedProducts => products.where((p) => p.selectedProduct).toList();
  bool loading01 = false;

  get counterSelectedProducts {
    int tmp = 0;
    selectedProducts?.forEach((p) => p.selectedProduct ? tmp++ : tmp += 0);
    return tmp;
  }

  get totalCostSelectedProducts {
    double tmp = 0;
    selectedProducts?.forEach((p) => p.selectedProduct ? tmp += p.selectedQuantity * p.cost : tmp += 0);
    return tmp;
  }

  get totalCostCheckedProducts {
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
  }

  signInAnonymously() async {
    AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
    firebaseUser = authResult.user;
    // database = new FirebaseDatabase();
    // databaseReferenceUsers = database.reference().child(DATABASE_PATH_users);
    // databaseReferenceUsers.onChildChanged.listen((event) {
    //   print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
    //   //sensors = toSensorList(event.snapshot.value);
    // });

    // databaseReferenceProducts = database.reference().child(DATABASE_PATH_prdocuts);
    // databaseReferenceProducts.onChildChanged.listen((event) {
    //   print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
    //   //sensors = toSensorList(event.snapshot.value);
    // });

    // databaseReferenceFactures = database.reference().child(DATABASE_PATH_commandes);
    // databaseReferenceFactures.onChildChanged.listen((event) {
    //   print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
    // });
    // notifyListeners();
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
        await getAllCommandes();
        await getAllEmails();
        await getAllProducts();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('stay_signed_in', false);
    client = null;
    user = null;
    products.forEach((p) => p.selectedProduct = false);
    notifyListeners();
  }

  Future<List<ModelClient>> getAllClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (internet == ConnectivityResult.none) {
      List<String> list = (prefs.getStringList('clients') ?? null);
      if (list != null) {
        clients.clear();
        list.forEach((e) {
          clients.add(ModelClient.fromJson(json.decode(e)));
        });
        notifyListeners();
        return clients;
      }
    }

    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_clients).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    clients.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        clients.add(ModelClient.fromJson(value));
      }
    });

    {
      List<String> array = new List<String>();
      clients.forEach((p) {
        array.add(json.encode(p.toJson()));
      });
      prefs.setStringList('clients', array);
    }

    notifyListeners();
    return clients;
  }

  Future<List<ModelFacture>> getAllCommandes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (internet == ConnectivityResult.none) {
      List<String> list = (prefs.getStringList('factures') ?? null);
      if (list != null) {
        factures.clear();
        list.forEach((e) {
          factures.add(ModelFacture.fromJson(json.decode(e)));
        });

        toSYNC_factures.forEach((p) {
          factures.add(p);
        });
        notifyListeners();
        return factures;
      }
    }

    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_commandes).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    factures.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        factures.add(ModelFacture.fromJson(value));
      }
    });

    {
      List<String> array = new List<String>();
      factures.forEach((p) {
        array.add(json.encode(p.toJson()));
      });
      prefs.setStringList('factures', array);
    }
    toSYNC_factures.forEach((p) {
      factures.add(p);
    });

    notifyListeners();
    return factures;
  }

  Future<List<ModelProduct>> getAllProductsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
      List<String> list = (prefs.getStringList('products') ?? null);
      if (list != null) {
        products.clear();
        list.forEach((e) {
          products.add(ModelProduct.fromJson(json.decode(e)));
        });
        notifyListeners();
        return products;
      }
   
  }

  int total_getAllProducts = 0;
  int current_total_getAllProducts = 0;

  Future<List<ModelProduct>> getAllProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (internet == ConnectivityResult.none) {
      List<String> list = (prefs.getStringList('products') ?? null);
      if (list != null) {
        products.clear();
        list.forEach((e) {
          products.add(ModelProduct.fromJson(json.decode(e)));
        });
        notifyListeners();
        return products;
      }
    }
    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_prdocuts).once();
    Map<dynamic, dynamic> mapResponse = snapshot.value;
    products.clear();
    mapResponse?.forEach((key, value) async {
      if (key.toString().isNotEmpty) {
        if (ModelProduct.fromJson(value) != null) products.add(ModelProduct.fromJson(value));
      }
    });
    total_getAllProducts = products.length-1;
    notifyListeners();
          // Directory tempDir = await getExternalStorageDirectory();
          Directory tempDir = await getTemporaryDirectory();
    for (int i = 0; i < products.length; i++) {
      products[i].imagePath[0] = await loadImage(products[i].imagePath[0]);
      
      continue;
      // current_total_getAllProducts = i;
      // notifyListeners();
      // int j = 0;
      // String url = await loadImage(products[i].imagePath[j]);

      // String localStorageFile = tempDir.path + "/" + products[i].imagePath[j];
      // print(localStorageFile);

      // final File tempFile = File(localStorageFile);
      // if (tempFile.existsSync()) {
      //   products[i].imagePath[j] = localStorageFile;
      //    notifyListeners();
      //   // continue;
      //   await tempFile.delete();
      // }
      // await tempFile.create();
      // // assert(await tempFile.readAsString() == "");
      // final StorageFileDownloadTask task =
      //     FirebaseStorage.instance.ref().child(products[i].imagePath[j]).writeToFile(tempFile);
      // try {
      //   FileDownloadTaskSnapshot fileDownloeded = await task.future;
      //   products[i].imagePath[j] = localStorageFile;
      // } on PlatformException catch (e) {
      //   // throw e.code;
      //   print(e.code);
      //   products[i].imagePath[j] = "assets/login_background.jpg" ;
      //   // return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
      // } catch (e) {
      //   print(e);
      //           products[i].imagePath[j] = "assets/login_background.jpg" ;
      //   // return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
      // }
      // continue;
      for (int j = 0; j < products.elementAt(i).imagePath.length; j++) {
      //   String url = await loadImage(products[i].imagePath[j]);
      //   Directory tempDir = await getExternalStorageDirectory();
      //   String localStorageFile = tempDir.path + "/" + products[i].imagePath[j];
      //   print(localStorageFile);

      //   final File tempFile = File(localStorageFile);
      //   if (tempFile.existsSync()) {
      //     continue;
      //     // await tempFile.delete();
      //   }
      //   await tempFile.create();
      //   // assert(await tempFile.readAsString() == "");
      //   final StorageFileDownloadTask task =
      //       FirebaseStorage.instance.ref().child(products[i].imagePath[j]).writeToFile(tempFile);
      //   try {
      //     FileDownloadTaskSnapshot fileDownloeded = await task.future;
      //     products[i].imagePath[j] = localStorageFile;
      //   } on PlatformException catch (e) {
      //     // throw e.code;
      //     print(e.code);
      //     // return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
      //   } catch (e) {
      //     print(e);
      //     // return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQkAAAC+CAMAAAARDgovAAAAbFBMVEUAAAD///+2trbv7+/y8vL19fX6+vrx8fG+vr6pqammpqaPj498fHz5+fmwsLCJiYnl5eXd3d2VlZXHx8egoKCFhYXDw8Pq6urW1tZxcXGZmZl3d3d7e3vQ0NBZWVna2tpmZmZNTU0qKipqamptl0nKAAACRklEQVR4nO3Vy5KbMBCF4WlJgLhKXGQwGNuTef93TDMTJ5NVNlRl838Ll9wUXdKRZL+9AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+C4Mvb4IvJPFCEi8nJ3F5DQon8e9H/Z9hu/+zkY+yl16kK41rjWll7kbRkhGJOvosyaWbT5v5mUlkNpNrXuhAWvE+D3OeWyfiXN7aQhqnXzONwWZ2EJf/eiOzubT64YrvvZb7Rca5MnKNNs+WayFxTLmWyk6ax7S3y9XKWC3pvOmfl0SROi/Psh51nWaZgr+Wseym3d59X3dd9uxiXYVo6+oyT8ugC+/rcoz1NEhVr3WZHkeXxWtYYldznC5fyr07ys2RbzjCu5QuSV9pycoaJbnT5n9eEm7TRWxip2IVv+yjBJmfU+g0mDyZWRrpB9mN1yPv3qfjjUoviZ701ZYPucqiy5N2+3HcnKk3eg0eTS5LDMtXEu5Iom8kBumnzySGKOG863FeEjrrq9x0OzPd5GU8krDH4Z2PVfdPfTQHuZix0+Nz00UUUuq+Gy91UR05PT7T2bvjAplpa4q+bo+KnjRpjmKtPxFBS5t2EUmZlKOOT3NeEjHUpS7ITrJOzSM2xjeLSWHXgl3rWkzTV6kusjV185SFWGfzEHwxpFKqeCRRfe/mL7J9JJ83aXBueN/aPt2D3D6S0UbaZbhvzoabP236/Iv+RhIvJPFCEi8/AeOuJz6xIWufAAAAAElFTkSuQmCC";
      //   }
          // products[i].imagePath[j] = await loadImage(products[i].imagePath[j]);
      }

      // AdvancedNetworkImage(
      //   products[i].imagePath.first,
      //   useDiskCache: true,
      //   cacheRule: CacheRule(maxAge: const Duration(days: 7)),
      //   retryLimit: 3,
      // );
      // print(products.elementAt(i).imagePath);
    }

    {
      List<String> array = new List<String>();
      products.forEach((p) {
        array.add(json.encode(p.saveSettings()));
      });
      prefs.setStringList('products', array);
    }

    notifyListeners();
    return products;
  }

  Future<List<String>> getAllEmails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (internet == ConnectivityResult.none) {
      admin_emails = (prefs.getStringList('admin_emails') ?? null);
      if (admin_emails != null) {
        return admin_emails;
      }
    }

    DataSnapshot snapshot = await database.reference().child(DATABASE_PATH_admin_emails).once();
    List<dynamic> mapResponse = snapshot.value;
    admin_emails.clear();
    mapResponse?.forEach((value) async {
      admin_emails.add(value.toString());
    });

    {
      prefs.setStringList('admin_emails', admin_emails);
    }

    notifyListeners();
    return admin_emails;
  }

  void genereateCurrentFacture() {
    tmp_currentFacture = new ModelFacture();

    List<ModelProduct> array = new List<ModelProduct>();
    selectedProducts.forEach((p) {
      if (p.selectedProduct && p.checked) {
        array.add(p);
        tmp_currentFacture.total += p.total_per_selectedQuantity;
      }
    });

    tmp_currentFacture.createdAt = new DateTime.now().millisecondsSinceEpoch.toString();
    tmp_currentFacture.user = user;
    tmp_currentFacture.client = client;
    tmp_currentFacture.valid = false;
    tmp_currentFacture.products = array;
  }

  Future<bool> saveFatures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (internet == ConnectivityResult.none) {
      for (int i = 0; i < toSYNC_factures.length; i++) {
        if (toSYNC_factures.elementAt(i) == currentFacture) return false;
      }
      List<String> list = (prefs.getStringList('toSYNCFacture') ?? List<String>());
      list.add(json.encode(currentFacture.toJson()));
      if (list != null) {
        toSYNC_factures.clear();
        list.forEach((e) {
          toSYNC_factures.add(ModelFacture.fromJson(json.decode(e)));
          toSYNC_factures.last.toSYNC = true;
        });
      }

      {
        List<String> array = new List<String>();
        toSYNC_factures.forEach((p) {
          array.add(json.encode(p.toJson()));
        });
        prefs.setStringList('toSYNCFacture', array);
      }

      toSYNC_factures.forEach((p) {
        factures.add(p);
      });

      notifyListeners();
      return true;
    }
    await database
        .reference()
        .child(DATABASE_PATH_commandes)
        .child(currentFacture.createdAt)
        .set(currentFacture.toJson());
    await getAllCommandes();
    currentFacture.toSYNC = false;
    toSYNC_factures.removeWhere((item) => item == currentFacture);
    factures.removeWhere((item) => item == currentFacture);
    {
      List<String> array = new List<String>();
      toSYNC_factures.forEach((p) {
        array.add(json.encode(p.toJson()));
      });
      prefs.setStringList('toSYNCFacture', array);
    }
    // factures.forEach((f) {
    //   if (f.createdAt == currentFacture.createdAt) currentFacture = f;
    // });
    notifyListeners();
    return true;
    // databaseReference.child("2").set({
    //   'title': 'Flutter in Action',
    //   'description': 'Complete Programming Guide to learn Flutter'
    // });
  }

  String currentFactureToHTML() {
    String tableBody = "";
    int total = 0;

    for (int i = 0; i < currentFacture.products.length; i++) {
      tableBody += " <tr>";
      tableBody += " <td style=\"width: 5%\"><b> " + (i + 1).toString() + "<br></b></td>";
      tableBody += " <td style=\"width: 50%\"><b> " + currentFacture.products.elementAt(i).name + "<br></b></td>";
      tableBody += " <td style=\"width: 10%\"><b> " +
          currentFacture.products.elementAt(i).selectedQP.toString() +
          "<br></b></td>";
      tableBody +=
          " <td style=\"width: 10%\"><b> " + currentFacture.products.elementAt(i).quantity.toString() + "<br></b></td>";
      tableBody +=
          " <td style=\"width: 10%\"><b> " + currentFacture.products.elementAt(i).cost.toString() + "<br></b></td>";
      tableBody += " <td style=\"width: 10%\"><b> 19.00<br></b></td>";
      tableBody +=
          " <td style=\"width: 10%\"><b> " + currentFacture.products.elementAt(i).total.toString() + "<br></b></td>";
      tableBody += " </tr>";
      total += currentFacture.products.elementAt(i).total;
    }

//first page 20 max

    String number_en_lettre = chiffreEnLettre(total);

    String clientBody = "";
    clientBody += "<p><b>Client: " + currentFacture.client.name + "</b></p>";
    clientBody += "<p>Adresse: " + currentFacture.client.name + "</p>";

    clientBody += "<pre>N RC: ####### &#9;| N FISCALE: #######</pre>";
    clientBody += "<pre>N ART: ####### </pre>";

    int pageCount = 1;

    String htmlContent = """
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
        height: """ +
        (29.7 * pageCount).toString() +
        """cm;
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
              """ +
        clientBody +
        """
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
""" +
        tableBody +
        """
            </tbody>
        </table>
        <div style="position: absolute; bottom: """ +
        (18 - currentFacture.products.length).toString() +
        """cm; left: 1cm;word-wrap: break-word;width: 50%;">
            <p>Cette facture est arretee au montant :</p>
            <p><b>""" +
        number_en_lettre +
        """</b></p>
            <p>Mode de paiment : <b>{{paimentMode}}</b></p>
        </div>
        <table style="position: absolute; bottom: """ +
        (14 - currentFacture.products.length).toString() +
        """cm; right: 1cm; border-collapse: collapse;border: 1px solid black; background-color: #f2f2f2">
            <tr>
                <td style="text-align:left;width:37.84mm; ">
                    <p><b>HORS TAXE (DA): </b></p>
                </td>
                <td style="text-align:right;width:44.01mm; ">
                    <p>""" +
        total.toString() +
        """ DZD</p>
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
                    <p> """ +
        (total * 0.19).toString() +
        """</p>
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
                    <p>""" +
        (26 + total * 1.19).toString() +
        """ DZD</p>
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

  String chiffreEnLettre(int chiffre) {
    String lettre = "";
    int centaine, dizaine, unite, reste, y;
    bool dix = false;

    reste = chiffre;
    for (int i = 1000000000; i >= 1; i = (i / 1000).toInt()) {
      y = (reste / i).toInt();
      if (y != 0) {
        centaine = (y / 100).toInt();
        dizaine = ((y - centaine * 100) / 10).toInt();
        unite = y - (centaine * 100) - (dizaine * 10);
        switch (centaine) {
          case 0:
            break;
          case 1:
            lettre += "cent ";
            break;
          case 2:
            if ((dizaine == 0) && (unite == 0))
              lettre += "deux cents ";
            else
              lettre += "deux cent ";
            break;
          case 3:
            if ((dizaine == 0) && (unite == 0))
              lettre += "trois cents ";
            else
              lettre += "trois cent ";
            break;
          case 4:
            if ((dizaine == 0) && (unite == 0))
              lettre += "quatre cents ";
            else
              lettre += "quatre cent ";
            break;
          case 5:
            if ((dizaine == 0) && (unite == 0))
              lettre += "cinq cents ";
            else
              lettre += "cinq cent ";
            break;
          case 6:
            if ((dizaine == 0) && (unite == 0))
              lettre += "six cents ";
            else
              lettre += "six cent ";
            break;
          case 7:
            if ((dizaine == 0) && (unite == 0))
              lettre += "sept cents ";
            else
              lettre += "sept cent ";
            break;
          case 8:
            if ((dizaine == 0) && (unite == 0))
              lettre += "huit cents ";
            else
              lettre += "huit cent ";
            break;
          case 9:
            if ((dizaine == 0) && (unite == 0))
              lettre += "neuf cents ";
            else
              lettre += "neuf cent ";
        }
        switch (dizaine) {
          case 0:
            break;
          case 1:
            dix = true;
            break;
          case 2:
            lettre += "vingt ";
            break;
          case 3:
            lettre += "trente ";
            break;
          case 4:
            lettre += "quarante ";
            break;
          case 5:
            lettre += "cinquante ";
            break;
          case 6:
            lettre += "soixante ";
            break;
          case 7:
            dix = true;
            lettre += "soixante ";
            break;
          case 8:
            lettre += "quatre-vingt ";
            break;
          case 9:
            dix = true;
            lettre += "quatre-vingt ";
        } // endSwitch(dizaine)

        switch (unite) {
          case 0:
            if (dix) lettre += "dix ";
            break;
          case 1:
            if (dix)
              lettre += "onze ";
            else
              lettre += "un ";
            break;
          case 2:
            if (dix)
              lettre += "douze ";
            else
              lettre += "deux ";
            break;
          case 3:
            if (dix)
              lettre += "treize ";
            else
              lettre += "trois ";
            break;
          case 4:
            if (dix)
              lettre += "quatorze ";
            else
              lettre += "quatre ";
            break;
          case 5:
            if (dix)
              lettre += "quinze ";
            else
              lettre += "cinq ";
            break;
          case 6:
            if (dix)
              lettre += "seize ";
            else
              lettre += "six ";
            break;
          case 7:
            if (dix)
              lettre += "dix-sept ";
            else
              lettre += "sept ";
            break;
          case 8:
            if (dix)
              lettre += "dix-huit ";
            else
              lettre += "huit ";
            break;
          case 9:
            if (dix)
              lettre += "dix-neuf ";
            else
              lettre += "neuf ";
        } // endSwitch(unite

        switch (i) {
          case 1000000000:
            if (y > 1)
              lettre += "milliards ";
            else
              lettre += "milliard ";
            break;
          case 1000000:
            if (y > 1)
              lettre += "millions ";
            else
              lettre += "million ";
            break;
          case 1000:
            lettre += "mille ";
        }
      }
      reste -= y * i;
      dix = false;
    }
    if (lettre.length == 0) lettre = "zero";
    return lettre;
  }

  int landscape_count = 1;
  // int portrait_count = 3;
  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    landscape_count = (prefs.getInt('landscape_count') ?? 1);
    // portrait_count = (prefs.getInt('portrait_count') ?? 3);
  }

  saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('landscape_count', landscape_count);
    // prefs.setInt('portrait_count', portrait_count);
  }
}

List<Color> myTheme = [Color.fromRGBO(104, 193, 139, 1.0), Color.fromRGBO(57, 178, 186, 1.0)];

Gradient myGradient = LinearGradient(colors: myTheme);
