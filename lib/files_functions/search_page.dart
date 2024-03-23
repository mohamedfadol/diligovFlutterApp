// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:pdftron_flutter/pdftron_flutter.dart' ;
//
// class SearchPage extends StatefulWidget {
//
//   final List<File> listOfPDFs;
//   final String text;
//
//   SearchPage(this.listOfPDFs , this.text);
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//
//           Expanded(
//             child: ListView(
//                 children: [
//
//                   //Here we display the full search for all the PDF files
//                   for(int i = 0 ; i < widget.listOfPDFs.length ; i++ )
//                     Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             GestureDetector(
//                                 child: Container(
//                                   padding: EdgeInsets.all(5),
//                                   width: 250,
//                                   height: 250,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey,
//                                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                                   ),
//                                   child: PdfDocumentLoader.openFile(
//                                       widget.listOfPDFs[i].path,
//                                       pageNumber: 1,
//                                       pageBuilder: (context, textureBuilder, pageSize) => textureBuilder()
//                                   ),
//                                 ),
//                                 onTap: () async {
//                                   await PdftronFlutter.openDocument(
//                                       widget.listOfPDFs[i].path);
//                                   await PdftronFlutter.startSearchMode(
//                                       widget.text, false, false);
//
//                                 }
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(basename(widget.listOfPDFs[i].path)),
//                             ),
//
//                           ],
//                         ),
//                       ),
//                     )
//                 ]
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
