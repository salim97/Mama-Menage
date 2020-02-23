import 'package:flutter/material.dart';
import 'package:mama_menage_v3/models/model_client.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';

class ClientAvatar extends StatefulWidget {
  ModelClient client;
   GestureTapCallback onTap;
  ClientAvatar({Key key, this.client, this.onTap}) : super(key: key);

  @override
  _ClientAvatarState createState() => _ClientAvatarState();
}

class _ClientAvatarState extends State<ClientAvatar> {
  MyAppState myAppState;
  Size windowsSize;
  // ModelClient get client => myAppState.clients.elementAt(widget.index);
  // get client => myAppState.clients.elementAt(widget.index);

  @override
  Widget build(BuildContext context) {
     myAppState = Provider.of<MyAppState>(context);
    Size windowsSize = MediaQuery.of(context).size;
    var minSize = windowsSize.height > windowsSize.width ? windowsSize.width : windowsSize.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => widget.onTap(),
              child: Container(
          height: minSize,
          width: minSize,
          child: ClipOval(
            child: Stack(
              children: <Widget>[

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Image.asset(
                    "assets/images/clientAvatarDefault.png",
                    fit: BoxFit.cover,
                    color:  myAppState.client == widget.client? Colors.green : Colors.black,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: windowsSize.height * 0.10,
                    width: windowsSize.width,
                    decoration: BoxDecoration(color: Color.fromRGBO(214, 214, 214, 1.0)),
                    child: Column(
                      children: <Widget>[
                        Text(widget.client.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10.0,),
                        Text(widget.client.phone, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              myAppState.client == widget.client? Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromRGBO(48, 196, 35, 1.0),
                        elevation: 0,
                        onPressed: null,
                      ),
                    ),
                  ) : Container()
              ],
            ),
          ),
        ),
      ),
    );
    // Stack(fit: StackFit.expand, overflow: Overflow.clip, children: <Widget>[
    //   Positioned(
    //       left: 0,
    //       right: 0,
    //       bottom: 0,
    //       top: 0,
    //       child:

    //       // Container(
    //       //   width: minSize,
    //       //   height: minSize,
    //       //   child: Container(
    //       //     height: windowsSize.height * 0.10,
    //       //     width: windowsSize.width,
    //       //     decoration: BoxDecoration(color: Color.fromRGBO(214, 214, 214, 1.0)),
    //       //     child: null
    //       //     // Column(
    //       //     //   children: <Widget>[Text("client.name"), Text("client.phone")],
    //       //     // ),
    //       //   ),
    //       //   decoration: BoxDecoration(
    //       //       image: DecorationImage(
    //       //         image: AssetImage("assets/images/clientAvatarDefault.png"),
    //       //         fit: BoxFit.cover,
    //       //       ),
    //       //       shape: BoxShape.circle,
    //       //       color: Color(0xFFe0f2f1)),
    //       // )

    //       ),
    // ])    ;
  }
}
