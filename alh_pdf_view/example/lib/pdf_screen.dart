import 'dart:typed_data';

import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:alh_pdf_view_example/pdf_page_info.dart';
import 'package:alh_pdf_view_example/pdf_view_bottom_bar.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PDFScreen extends StatefulWidget {
  final String? path;
  Uint8List? bytes;

  PDFScreen({
    this.path,
    this.bytes,
    super.key,
  });

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool isActive = true;
  double defaultScale = 1.0;
  double top = 200.0;
  bool enableSwipe = true;

  AlhPdfViewController? pdfViewController;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Document Portrait'),
          ),
          body: Stack(
            children: <Widget>[
              Column(
                children: [
                  Expanded(
                    child: AlhPdfView(
                      spacing: 100,
                      backgroundColor: Colors.white,
                      enableDefaultScrollHandle: true,
                      filePath: widget.path,
                      bytes: widget.bytes,
                      enableSwipe: true,
                      nightMode: false,
                      password: 'password',
                      fitEachPage: false,
                      showScrollbar: true,
                      fitPolicy: orientation == Orientation.portrait
                          ? FitPolicy.both
                          : FitPolicy.width,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: false,
                      defaultZoomFactor: defaultScale,
                      pageSnap: true,
                      onRender: (pages) {
                        setState(() {
                          this.pages = pages + 1;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        print(error.toString());
                      },
                      onViewCreated: (controller) {
                        pdfViewController = controller;
                      },
                      onPageChanged: (int page, int total) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      onZoomChanged: (zoom) {
                        print('On zoom changed: $zoom');
                      },
                      onTap: () {
                        print('onTap called');
                      },
                    ),
                  ),
                  if (orientation == Orientation.portrait)
                    PdfViewBottomBar(
                      pdfViewController: pdfViewController,
                      currentPage: currentPage,
                      totalPages: pages,
                    ),
                ],
              ),
              if (errorMessage.isEmpty)
                if (!isReady)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  PdfPageInfo(
                    currentPage: currentPage,
                    totalPages: pages,
                  )
              else
                Center(child: Text(errorMessage)),
            ],
          ),
        );
      },
    );
  }
}
