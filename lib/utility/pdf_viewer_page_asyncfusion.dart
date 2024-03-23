import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerPageSyncfusionPackage extends StatefulWidget {
  final String file;
  final String fileName;
  const PDFViewerPageSyncfusionPackage({Key? key,required this.file,required this.fileName,}) : super(key: key);

  @override
  State<PDFViewerPageSyncfusionPackage> createState() => _PDFViewerPageSyncfusionPackageState();
}

class _PDFViewerPageSyncfusionPackageState extends State<PDFViewerPageSyncfusionPackage> {
  bool loading = true;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    setState(() {
      loading = false;
    });
    super.initState();
  }

  int pages = 0;
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    // final name = basename(widget.file.path);
    final text = '${indexPage + 1} of $pages';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions:
             [
               IconButton(
                 icon: Icon(
                   Icons. bookmark,
                   color: Colors.white,
                 ),
                 onPressed: () {
                   _pdfViewerKey.currentState?.openBookmarkView();
                 },
               ),
          Center(child: Text(text)),
          IconButton(
            icon: Icon(Icons.chevron_left, size: 32),
            onPressed: () {
              _pdfViewerController!.previousPage();
            },
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 32),
            onPressed: () {
              _pdfViewerController!.nextPage();
            },
          ),
        ]
            ,
      ),

      body: loading ? Center(child: CircularProgressIndicator(),) : SfPdfViewer.network(
         widget.file!,
        controller: _pdfViewerController,
        key: _pdfViewerKey,
        enableTextSelection: true
      ),
    );
  }
}
