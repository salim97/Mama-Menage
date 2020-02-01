import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mainwindow.dart';
import 'pages/page_all_products.dart';
import 'pages/page_clients.dart';
import 'pages/page_login.dart';
import 'pages/page_products_details.dart';
import 'pages/page_products_quantity.dart';
import 'pages/page_validation.dart';
import 'providers/my_app_state.dart';

void main() => runApp(EasyLocalization(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
        var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
       data: data,
          child: MultiProvider(
         providers: [
           ChangeNotifierProvider(create: (_) => MyAppState()),
        ],
        child: MaterialApp(
      
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          //app-specific localization
          EasylocaLizationDelegate(
            locale: data.savedLocale,
            path: 'lang',
            //useOnlyLangCode: true,
            // loadPath: 'https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs'
          ),
        ],
        supportedLocales: [Locale('fr', 'FR')],
        locale: data.locale,
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: MainWindow(),
          //  home: Page_Clients(),
        ),
      ),
    );
  }
}

