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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: this._handleTapZoomOut,
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: this._handleTapFirstPage,
            icon: const Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: this._handleTapPreviousPage,
            icon: const Icon(Icons.navigate_before),
          ),
          IconButton(
            onPressed: this._handleTapNextPage,
            icon: const Icon(Icons.navigate_next),
          ),
          IconButton(
            onPressed: this._handleTapLastPage,
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(
            onPressed: this._handleTapZoomIn,
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTapFirstPage() async {
    await this.pdfViewController?.setPage(page: 0);
  }

  Future<void> _handleTapPreviousPage() async {
    await this.pdfViewController?.goToPreviousPage();
  }

  Future<void> _handleTapNextPage() async {
    await this.pdfViewController?.goToNextPage(withAnimation: false);
  }

  Future<void> _handleTapLastPage() async {
    await this.pdfViewController?.setPage(page: this.totalPages - 2);
  }

  Future<void> _handleTapZoomOut() async {
    if (this.pdfViewController != null) {
      final currentZoom = await this.pdfViewController!.getZoom();
      await this.pdfViewController!.setZoom(zoom: currentZoom - _zoomFactor);
    }
  }

  Future<void> _handleTapZoomIn() async {
    if (this.pdfViewController != null) {
      final currentZoom = await this.pdfViewController!.getZoom();
      await this.pdfViewController!.setZoom(zoom: currentZoom + _zoomFactor);
    }
  }
}
