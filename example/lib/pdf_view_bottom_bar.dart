import 'package:alh_pdf_view/lib.dart';
import 'package:flutter/material.dart';

class PdfViewBottomBar extends StatelessWidget {
  final AlhPdfViewController? pdfViewController;
  final int currentPage;
  final int totalPages;
  final double currentZoom;

  final double zoomFactor = 0.1;

  const PdfViewBottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.currentZoom,
    this.pdfViewController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (currentZoom > 1) {
                if (pdfViewController != null) {
                  pdfViewController!.setZoom(zoom: currentZoom - zoomFactor);
                }
              }
            },
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              if (pdfViewController != null) {
                pdfViewController!.setPageWithAnimation(page: 0);
              }
            },
            icon: const Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: () {
              if (pdfViewController != null && currentPage != 0) {
                pdfViewController!.setPageWithAnimation(page: currentPage - 1);
              }
            },
            icon: const Icon(Icons.navigate_before),
          ),
          IconButton(
            onPressed: () {
              if (pdfViewController != null && currentPage != totalPages) {
                pdfViewController!.setPageWithAnimation(page: currentPage + 1);
              }
            },
            icon: const Icon(Icons.navigate_next),
          ),
          IconButton(
            onPressed: () {
              if (pdfViewController != null) {
                pdfViewController!.setPageWithAnimation(page: totalPages - 2);
              }
            },
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(
            onPressed: () {
              if (pdfViewController != null) {
                pdfViewController!.setZoom(zoom: currentZoom + zoomFactor);
              }
            },
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
    );
  }
}
