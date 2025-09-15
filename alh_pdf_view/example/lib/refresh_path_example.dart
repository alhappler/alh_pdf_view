import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/material.dart';

class RefreshPathExample extends StatefulWidget {
  final String path;
  final String updatedPath;

  const RefreshPathExample({
    required this.path,
    required this.updatedPath,
    super.key,
  });

  @override
  State<RefreshPathExample> createState() => _RefreshPathExampleState();
}

class _RefreshPathExampleState extends State<RefreshPathExample> {
  late String path = widget.path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh path example'),
        actions: [
          IconButton(
            onPressed: () {
              final path = widget.path;
              setState(() {
                this.path = this.path == path ? widget.updatedPath : path;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AlhPdfView(filePath: path),
    );
  }
}
