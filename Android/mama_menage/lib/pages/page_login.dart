import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'page_all_products.dart';

class Page_Login extends StatefulWidget {
  @override
  _Page_LoginState createState() => _Page_LoginState();
}

class _Page_LoginState extends State<Page_Login> {
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myAppState = Provider.of<MyAppState>(context, listen: false);
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        //emailController.text = (prefs.getString('userName') ?? "");
      });
    });
    // if (DEV_MODE) 
    {
      setState(() {
        emailController.text = "salim";
        passwordController.text = "123456";
      });
    }
  }

  login() async {
    String userName = emailController.text;
    String password = passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      myAppState.flushbar(
          context: context,
           
          message: AppLocalizations.of(context).tr('p_login_msg_field_empty'),
          color: Colors.orange);
      return;
    }
    bool userFound = await myAppState.login(email: userName, password: password);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
    if (userFound ) {
      if (context == null) return;
      myAppState.flushbar(context: context, message: AppLocalizations.of(context).tr('p_login_msg_success'), color: Colors.green);
        // Navigator.of(context)
                      // .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_AllProdutcs()));
    } else {
      myAppState.flushbar(context: context, message: AppLocalizations.of(context).tr('p_login_msg_failed'), color: Colors.red);
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool visiblelogin = true;
  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    //for showing loading

    // this below line is used to make notification bar transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image.asset(
            //TODO update this
            'assets/big_mama.png',
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
            //     gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
            //   // Colors.white.withOpacity(1),
            //   // Colors.white.withOpacity(.6),
            //   Color.fromRGBO(104, 193, 139, 1.0),
            //     Color.fromRGBO(57, 178, 186, 1.0)
            // ])
color: Colors.white            
            ),
          ),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: windowsSize.height * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(),
                      Text(
                        AppLocalizations.of(context).tr('app_name'),
                        style: TextStyle(
                          fontSize: 27.0,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        //TODO update this
                        AppLocalizations.of(context).tr('p_login_label_sublogo_msg'),
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Container(
                              width: windowsSize.width / 2,
                              child: new TextFormField(
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).tr('p_login_label_username'),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            width: windowsSize.width / 2,
                            child: new TextFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).tr('p_login_label_password'),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                  icon: _isPasswordHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              obscureText: _isPasswordHidden,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      // RaisedButton(onPressed: () {
                      //     login();
                      //   },
                      //   child: Text(
                      //       'Login',
                      //       style: TextStyle(fontSize: 16, ),
                      //     ),
                      //   ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            visiblelogin = false;
                          });
                          await login();
                          if(mounted)
                          setState(() {
                            visiblelogin = true;
                          });
                        },
                        child: visiblelogin
                            ? Container(
                                height: 50,
                                width: windowsSize.width / 3,
                                decoration: BoxDecoration(
                                  gradient: customGradient,
                                  color: Colors.green, borderRadius: BorderRadius.circular(50)),
                                margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Center(
                                    child: Text(
                                 AppLocalizations.of(context).tr('p_login_btn'),
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                )),
                              )
                            : CircularProgressIndicator(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
