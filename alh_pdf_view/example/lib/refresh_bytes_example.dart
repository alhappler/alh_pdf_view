import 'dart:typed_data';

import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/material.dart';

class RefreshBytesExample extends StatefulWidget {
  final Uint8List bytes;
  final Uint8List updatedBytes;

  const RefreshBytesExample({
    required this.bytes,
    required this.updatedBytes,
    super.key,
  });

  @override
  State<RefreshBytesExample> createState() => _RefreshBytesExampleState();
}

class _RefreshBytesExampleState extends State<RefreshBytesExample> {
  late Uint8List bytes = this.widget.bytes;
  FitPolicy fitPolicy = FitPolicy.width;
  bool showScrollbar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refresh Example"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                this.bytes = this.widget.updatedBytes;
                this.fitPolicy = this.fitPolicy == FitPolicy.height
                    ? FitPolicy.width
                    : FitPolicy.height;
                this.showScrollbar = !this.showScrollbar;
              });
            },
            icon: const Icon(Icons.change_circle),
          ),
        ],
      ),
      body: AlhPdfView(
        spacing: 100,
        backgroundColor: Colors.white,
        enableDefaultScrollHandle: true,
        bytes: this.bytes,
        fitPolicy: this.fitPolicy,
        showScrollbar: this.showScrollbar,
      ),
    );
  }
}
