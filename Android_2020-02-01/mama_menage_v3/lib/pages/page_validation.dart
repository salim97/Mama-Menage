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
import 'package:pdf_render/pdf_render_widgets.dart';
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
      onHTMLtoPDF();
      return;
    }
  }

  onHTMLtoPDF() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    Directory tempDir = await getApplicationDocumentsDirectory();
    // Directory tempDir = await getDownloadsDirectory();
    // Directory tempDir = await getTemporaryDirectory();

    var targetPath = tempDir.path;
    var targetFileName = "example_pdf_file7";

    String htmlContent = myAppState.currentFactureToHTML();

    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(htmlContent, targetPath, targetFileName);

    setState(() {
      _pdf_path = generatedPdfFile.path;
      print(_pdf_path);
    });

// document =  await PDFDocument.fromFile(generatedPdfFile);
  }

  onPDF() async {
    await onHTMLtoPDF();
    OpenFile.open(_pdf_path);
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

          final Email email = Email(
            recipients: [selected],
            body: "",
            subject: 'Commande ' + myAppState.currentFacture.createdAt,
            attachmentPath: _pdf_path,
            isHTML: false,
          );

          await FlutterEmailSender.send(email);
        });
  }

  String _pdf_path = "";
  //  PDFDocument document ;
  static const scale = 100.0 / 72.0;
  static const margin = 4.0;
  static const padding = 1.0;
  static const wmargin = (margin + padding) * 2;

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
                  child: _pdf_path.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: PdfDocumentLoader(
                          filePath: _pdf_path,
                          documentBuilder: (context, pdfDocument, pageCount) => LayoutBuilder(
                              builder: (context, constraints) => ListView.builder(
                                  itemCount: pageCount,
                                  itemBuilder: (context, index) => Container(
                                      margin: EdgeInsets.all(margin),
                                      padding: EdgeInsets.all(padding),
                                      color: Colors.black12,
                                      child: PdfPageView(
                                          pdfDocument: pdfDocument,
                                          pageNumber: index + 1,
                                          // calculateSize is used to calculate the rendering page size
                                          calculateSize: (pageWidth, pageHeight, aspectRatio) => Size(
                                              constraints.maxWidth - wmargin,
                                              (constraints.maxWidth - wmargin) / aspectRatio))))),
                        ))),
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
