import 'dart:async';
import 'dart:io';

import 'package:alh_pdf_view_example/pdf_screen.dart';
import 'package:alh_pdf_view_example/refresh_bytes_example.dart';
import 'package:alh_pdf_view_example/refresh_path_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(
      const MaterialApp(
        title: 'Alh PDF View',
        home: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String smallPdfPath = '';
  String linkPdfPath = '';

  Uint8List smallPdfBytes = Uint8List(0);
  Uint8List linkPdfBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pdfFile = await this.fromAsset('assets/sample.pdf', 'sample.pdf');
      final linkPdfFile = await this.fromAsset(
        'assets/sampleWithLink.pdf',
        'sampleWithLink.pdf',
      );
      setState(
        () {
          this.smallPdfPath = pdfFile.path;
          this.smallPdfBytes = pdfFile.readAsBytesSync();
          this.linkPdfPath = linkPdfFile.path;
          this.linkPdfBytes = linkPdfFile.readAsBytesSync();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                this._getButtonWithPushExample(
                  title: "Open small PDF with path",
                  widgetToPush: PDFScreen(path: this.smallPdfPath),
                ),
                this._getButtonWithPushExample(
                  title: "Open small PDF with bytes",
                  widgetToPush: PDFScreen(bytes: this.smallPdfBytes),
                ),
                this._getButtonWithPushExample(
                  title: "Refresh bytes and all others example",
                  widgetToPush: RefreshBytesExample(
                    bytes: this.smallPdfBytes,
                    updatedBytes: this.linkPdfBytes,
                  ),
                ),
                this._getButtonWithPushExample(
                  title: "Refresh path example",
                  widgetToPush: RefreshPathExample(
                    path: this.smallPdfPath,
                    updatedPath: this.linkPdfPath,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _getButtonWithPushExample({
    required String title,
    required Widget widgetToPush,
  }) {
    return ElevatedButton(
      onPressed: () {
        unawaited(
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widgetToPush,
            ),
          ),
        );
      },
      child: Text(title),
    );
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    final Completer<File> completer = Completer();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final File file = File("${dir.path}/$filename");
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!\n$e');
    }

    return completer.future;
  }
}
