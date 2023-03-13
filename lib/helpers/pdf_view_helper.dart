// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../activities/common_helpers/app_bar.dart';
import '../resources_helper/strings.dart';

class PdfViewHelper extends StatefulWidget {
  PdfViewHelper(this.commonHelper, this.url, this.title);

  final CommonHelper commonHelper;

  final String url, title;

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewHelper> {
  // PDFDocument? document;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // loadDocument();
  }

  // loadDocument() async {
  //   document = await PDFDocument.fromURL(widget.url);
  //   setState(() => _isLoading = false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: Center(
            // child: _isLoading
            //     ? Center(child: CircularProgressIndicator())
            //     : /*PDFViewer(document: document!, zoomSteps: 1)*/
            child: SfPdfViewer.network(widget.url, key: _pdfViewerKey)));
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: widget.title,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }
}
