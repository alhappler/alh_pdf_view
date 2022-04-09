import 'package:flutter/material.dart';

class PdfPageInfo extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PdfPageInfo({
    required this.currentPage,
    required this.totalPages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          'Page ${currentPage + 1}/${totalPages - 1}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
