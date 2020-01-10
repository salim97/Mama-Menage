import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/page_all_products.dart';
import 'pages/page_login.dart';
import 'pages/page_products_details.dart';
import 'pages/page_products_quantity.dart';
import 'pages/page_validation.dart';
import 'providers/my_app_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
         ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Page_Login(),
        // home: Page_AllProdutcs(),
      ),
    );
  }
}

