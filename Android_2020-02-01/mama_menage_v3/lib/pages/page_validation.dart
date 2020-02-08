import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:mama_menage_v3/components/askUser.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as w;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Page_Validation extends StatefulWidget {
  Page_Validation({Key key}) : super(key: key);

  @override
  _Page_ValidationState createState() => _Page_ValidationState();
}

class _Page_ValidationState extends State<Page_Validation> {
  final TextEditingController _textEditingController = TextEditingController();
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myAppState = Provider.of<MyAppState>(context, listen: false);
    if (myAppState.currentFacture != null) {
      String textOutput = "";
      textOutput += "Commande numero " + myAppState.currentFacture.createdAt + " \n";
      if (myAppState.user.isPriceVisible) {
        myAppState.currentFacture.products?.forEach((p) {
          textOutput += "\nproduct name = " + p.name;
          textOutput += "\nproduct cost = " + p.cost.toString();
          textOutput += "\nproduct quantity = " + p.quantity.toString();
          textOutput += "\nproduct total price = " + p.total.toString();
          textOutput += "\n-----------------------------------------";
        });
        textOutput += "total facture is " + myAppState.totalCostSelectedProducts.toString();
      }

      _textEditingController.text = textOutput;
      return;
    }
    //     Future.delayed(Duration(seconds: 1)).then((_) async {
    //   myAppState.flushbar(context: context, message: "facture was send with seccuss", color: Colors.green);
    //   //readProducts();
    // });

    // String textOutput = "";
    // textOutput += "Commande numero XX \n";
    // if (myAppState.user.isPriceVisible) {
    //   myAppState.selectedProducts?.forEach((p) {
    //     if (p.checked) {
    //       textOutput += "\nproduct name = " + p.name;
    //       textOutput += "\nproduct cost = " + p.cost.toString();
    //       textOutput += "\nproduct quantity = " + p.quantity.toString();
    //       textOutput += "\nproduct total price = " + p.total.toString();
    //       textOutput += "\n-----------------------------------------";
    //     }
    //   });
    //   textOutput += "total facture is " + myAppState.totalCostSelectedProducts.toString();
    // }

    // _textEditingController.text = textOutput;
  }
  
  onHTMLtoPDF() async {

    Directory tempDir = await getApplicationDocumentsDirectory();

var targetPath = tempDir.path;
var targetFileName = "example_pdf_file" ;
File generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
    myAppState.currentFactureToHTML(), targetPath, targetFileName);
  
     OpenFile.open(targetPath + '/example_pdf_file.pdf');
  }

  onPDF() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
onHTMLtoPDF();
  }

  onGMAIL() async {
    await myAppState.getAllEmails();
    List<Widget> m_actions = new List<Widget>();
    for (int i = 0; i < myAppState.admin_emails.length; i++)
      m_actions.add(CupertinoActionSheetAction(
        child: Text(myAppState.admin_emails.elementAt(i)),
        onPressed: () {
          Navigator.pop(context, myAppState.admin_emails.elementAt(i));
        },
      ));

    containerForSheet(
        context: context,
        child: CupertinoActionSheet(
          title: const Text('ADMIN MAILS'),
          message: const Text('select one of those mails'),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, '');
            },
          ),
          actions: m_actions,
        ),
        callback: (String selected) async {
          if (selected == null) return;
          if (!selected.contains("@")) return;

          String textOutput = "";
          textOutput += "Commande numero XX \n";

          myAppState.selectedProducts?.forEach((p) {
            if (p.checked) {
              textOutput += "\nproduct name = " + p.name;
              textOutput += "\nproduct cost = " + p.cost.toString();
              textOutput += "\nproduct quantity = " + p.quantity.toString();
              textOutput += "\nproduct total price = " + p.total.toString();
              textOutput += "\n-----------------------------------------";
            }
          });
          textOutput += "total facture is " + myAppState.totalCostSelectedProducts.toString();

          final Email email = Email(
            recipients: [selected],
            body: textOutput,
            subject: 'LA FACTEEEEUUUURR',
            isHTML: false,
          );

          await FlutterEmailSender.send(email);
        });
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: myTheme))),
        title: Text(
          AppLocalizations.of(context).tr('p_validation_appBar_title'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  myAppState.user.isPriceVisible
                      ? RaisedButton(
                          color: Colors.green,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                MdiIcons.filePdfBox,
                                color: Colors.white,
                              ),
                              VerticalDivider(
                                color: Colors.orange,
                              ),
                              Text(
                                "PDF",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onPressed: () {
                            onPDF();
                          },
                        )
                      : Container(),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    color: Colors.green,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          MdiIcons.mailbox,
                          color: Colors.white,
                        ),
                        VerticalDivider(
                          color: Colors.orange,
                        ),
                        Text(
                          "SEND",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () {
                      onGMAIL();
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
