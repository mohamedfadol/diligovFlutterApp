import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
class CustomPdfView extends StatelessWidget {
  final String path;
  const CustomPdfView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDFView(
        fitEachPage: true,
        filePath: path,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        nightMode: false,
        onPageChanged: (int? currentPage, int? totalPages) {
          print("Current page: $currentPage!, Total pages: $totalPages!");
          // You can use this callback to keep track of the current page.
        },
      ),
    );
  }
}
