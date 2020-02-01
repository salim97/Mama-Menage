import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
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
        Future.delayed(Duration(seconds: 1)).then((_) async {
      myAppState.flushbar(context: context, message: "facture was send with seccuss", color: Colors.green);
      //readProducts();
    });

    String textOutput = "";
    textOutput += "Commande numero XX \n";
    if (myAppState.user.isPriceVisible) {
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
    }

    _textEditingController.text = textOutput;
  }

  onPDF() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    final w.Document pdf = w.Document();
    List<List<String>> tableData = new List<List<String>>();
    // [
    //   <String>['Date', 'PDF Version', 'Acrobat Version'],
    //   <String>['1993', 'PDF 1.0', 'Acrobat 1'],
    //   <String>['1994', 'PDF 1.1', 'Acrobat 2'],
    //   <String>['1996', 'PDF 1.2', 'Acrobat 3'],
    //   <String>['1999', 'PDF 1.3', 'Acrobat 4'],
    //   <String>['2001', 'PDF 1.4', 'Acrobat 5'],
    //   <String>['2003', 'PDF 1.5', 'Acrobat 6'],
    //   <String>['2005', 'PDF 1.6', 'Acrobat 7'],
    //   <String>['2006', 'PDF 1.7', 'Acrobat 8'],
    //   <String>['2008', 'PDF 1.7', 'Acrobat 9'],
    //   <String>['2009', 'PDF 1.7', 'Acrobat 9.1'],
    //   <String>['2010', 'PDF 1.7', 'Acrobat X'],
    //   <String>['2012', 'PDF 1.7', 'Acrobat XI'],
    //   <String>['2017', 'PDF 2.0', 'Acrobat DC'],
    // ];
    tableData.add(<String>[
      "N°",
      "Name",
      "Cost",
      "Quantity",
      "Total",
    ]);
    for (int i = 0; i < myAppState.selectedProducts.length; i++) {
      tableData.add(<String>[
        (i + 1).toString(),
        myAppState.selectedProducts.elementAt(i).name,
        myAppState.selectedProducts.elementAt(i).cost.toString(),
        myAppState.selectedProducts.elementAt(i).quantity.toString(),
        myAppState.selectedProducts.elementAt(i).total.toString(),
      ]);
    }
    tableData.add(<String>[
      " ",
      " ",
      " ",
      " ",
      myAppState.totalCostSelectedProducts.toString(),
    ]);

    pdf.addPage(w.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: w.CrossAxisAlignment.start,
        header: (w.Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return w.Container(
              alignment: w.Alignment.centerRight,
              margin: const w.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const w.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const w.BoxDecoration(border: w.BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
              child: w.Text('Portable Document Format',
                  style: w.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)));
        },
        footer: (w.Context context) {
          return w.Container(
              alignment: w.Alignment.centerRight,
              margin: const w.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: w.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: w.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)));
        },
        build: (w.Context context) => <w.Widget>[
              w.Header(
                  level: 0,
                  child: w.Row(
                      mainAxisAlignment: w.MainAxisAlignment.spaceBetween,
                      children: <w.Widget>[w.Text('Portable Document Format', textScaleFactor: 2), w.PdfLogo()])),
              w.Paragraph(
                  text:
                      'The Portable Document Format (PDF) is a file format developed by Adobe in the 1990s to present documents, including text formatting and images, in a manner independent of application software, hardware, and operating systems. Based on the PostScript language, each PDF file encapsulates a complete description of a fixed-layout flat document, including the text, fonts, vector graphics, raster images and other information needed to display it. PDF was standardized as an open format, ISO 32000, in 2008, and no longer requires any royalties for its implementation.'),
              w.Header(level: 1, text: 'History and standardization'),
              w.Paragraph(
                  text:
                      'The PDF file format has changed several times, and continues to evolve, along with the release of new versions of Adobe Acrobat. There have been nine versions of PDF and the corresponding version of the software:'),
              w.Table.fromTextArray(context: context, data: tableData),
              w.Padding(padding: const w.EdgeInsets.all(10)),
              w.Paragraph(text: 'Text is available under the Creative Commons Attribution Share Alike License.')
            ]));

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    final File file = File(tempPath + '/example.pdf');
    file.writeAsBytesSync(pdf.save());
    OpenFile.open(tempPath + '/example.pdf');
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
        title: Text(AppLocalizations.of(context).tr('p_validation_appBar_title'),),
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
