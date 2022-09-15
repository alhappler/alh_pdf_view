import 'dart:async';
import 'dart:io';

import 'package:alh_pdf_view_example/pdf_screen.dart';
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
  String pathSmallPDF = '';
  Uint8List bytesSmallPDF = Uint8List(0);

  String pathPDFWithoutEndingPDF = '';
  String pathInvalidPDF = '';

  @override
  void initState() {
    super.initState();
// ignore: discarded_futures,
    fromAsset('assets/sample.pdf', 'sample.pdf').then((f) {
      setState(() {
        pathSmallPDF = f.path;
        bytesSmallPDF = f.readAsBytesSync();
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
// ignore: discarded_futures,
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFScreen(path: pathSmallPDF),
                      ),
                    );
                  },
                  child: const Text("Open small PDF with path"),
                ),
                ElevatedButton(
                  onPressed: () {
// ignore: discarded_futures,
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFScreen(bytes: bytesSmallPDF),
                      ),
                    );
                  },
                  child: const Text("Open small PDF with bytes"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
