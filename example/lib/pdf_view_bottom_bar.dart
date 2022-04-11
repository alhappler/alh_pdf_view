import 'package:alh_pdf_view/lib.dart';
import 'package:flutter/material.dart';

class PdfViewBottomBar extends StatelessWidget {
  static const double _zoomFactor = 0.1;

  final AlhPdfViewController? pdfViewController;
  final int currentPage;
  final int totalPages;

  const PdfViewBottomBar({
    required this.currentPage,
    required this.totalPages,
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
            onPressed: _handleTapZoomOut,
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: _handleTapFirstPage,
            icon: const Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: _handleTapPreviousPage,
            icon: const Icon(Icons.navigate_before),
          ),
          IconButton(
            onPressed: _handleTapNextPage,
            icon: const Icon(Icons.navigate_next),
          ),
          IconButton(
            onPressed: _handleTapLastPage,
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(
            onPressed: _handleTappZoomIn,
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
    );
  }

  void _handleTapFirstPage() {
    if (pdfViewController != null) {
      pdfViewController!.setPageWithAnimation(page: 0);
    }
  }

  void _handleTapPreviousPage() {
    if (pdfViewController != null && currentPage != 0) {
      pdfViewController!.setPageWithAnimation(page: currentPage - 1);
    }
  }

  void _handleTapNextPage() {
    if (pdfViewController != null && currentPage != totalPages) {
      pdfViewController!.setPageWithAnimation(page: currentPage + 1);
    }
  }

  void _handleTapLastPage() {
    if (pdfViewController != null) {
      pdfViewController!.setPageWithAnimation(page: totalPages - 2);
    }
  }

  Future<void> _handleTapZoomOut() async {
    if (pdfViewController != null) {
      final currentZoom = await pdfViewController!.getZoom();
      await pdfViewController!.setZoom(zoom: currentZoom - _zoomFactor);
    }
  }

  Future<void> _handleTappZoomIn() async {
    if (pdfViewController != null) {
      final currentZoom = await pdfViewController!.getZoom();
      await pdfViewController!.setZoom(zoom: currentZoom + _zoomFactor);
    }
  }
}
