// import 'dart:io';
//
// import 'package:diligov/files_functions/search_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:pdftron_flutter/pdftron_flutter.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path/path.dart';
//
// class FilesPage extends StatefulWidget {
//   const FilesPage({Key? key}) : super(key: key);
//
//   @override
//   State<FilesPage> createState() => _FilesPageState();
// }
//
// class _FilesPageState extends State<FilesPage> {
//
//
//
//   String _document = "";
//   String fileName ="";
//   bool _showViewer = true;
//   String searchText = "";
//   List<File> listOfUsersPDF = [];
//   List<String> listOfPDFtext = [];
//
//
//   //Function to add a file from the device storage to the app
//   Future<File?> pickFile() async {
//
//
//     Directory? dir = await Directory('/storage/emulated/0/Documents/pdfTest').create(recursive: true);
//
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//
//     );
//
//     fileName = await result!.names.first!;
//     bool fileExist = false;
//
//     if (result == null) return null;
//     _document = result.paths.first!;
//     for(int i = 0 ; i < listOfUsersPDF.length ; i++){
//       if(listOfUsersPDF[i].path == result.paths.first!){
//         return null;
//       }
//
//     }
//
//     setState(() {
//       listOfUsersPDF.add(File(result.paths.first!));
//     });
//
//     //Load an existing PDF document.
//     final PdfDocument document =
//     PdfDocument(inputBytes: File(result.paths.first!).readAsBytesSync());
// //Extract the text from all the pages.
//     String text = PdfTextExtractor(document).extractText();
// //Dispose the document.
//     document.dispose();
//     setState(() {
//       listOfPDFtext.add(text);
//     });
//
//     return File(result.paths.first ?? '');
//   }
//
//   void saveFile() async {
//     var status = await Permission.storage.request();
//     print(status.isGranted);// permission_handler
//     if (status.isGranted) {
//       Directory? directory;
//
//       if (Platform.isIOS) {
//         // create a folder with the name of the app
//         directory = await getApplicationDocumentsDirectory(); // path_provider
//       } else {
//         // global download folder
//         if (await Permission.manageExternalStorage
//             .request()
//             .isGranted) {
//
//         }
//         directory = Directory('/storage/emulated/0/Documents/pdfTest');
//       }
//
//       var doc = startLeadingNavButtonPressedListener(() async {
//
//         var path = await PdftronFlutter.saveDocument();
//         var file = File(path!);
//
//
//         if (await file.exists()) {
//           if(await directory!.exists()){
//             file.copySync(directory.path + '/${fileName}');}
//           else{
//             await file.copy(directory.path + '/${fileName}');
//           }
//         }});
//
//
//       // delete the original file if desired
//
//     }
//
//   }
//
//
//
//
//   void showViewer() async {
//     // opening without a config file will have all functionality enabled.
//     // await PdftronFlutter.openDocument(_document);
//
//     var config = Config();
//     // How to disable functionality:
//     //      config.disabledElements = [Buttons.shareButton, Buttons.searchButton];
//     //      config.disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
//     // Other viewer configurations:
//     //      config.multiTabEnabled = true;
//     //      config.customHeaders = {'headerName': 'headerValue'};
//
//     // An event listener for document loading
//     var documentLoadedCancel = startDocumentLoadedListener((filePath) {
//       print("document loaded: $filePath");
//     });
//
//
//
//     await PdftronFlutter.openDocument(_document, config: config);
//
//     try {
//       // The imported command is in XFDF format and tells whether to add, modify or delete annotations in the current document.
//       PdftronFlutter.importAnnotationCommand(
//           "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
//               "    <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">\n" +
//               "      <add>\n" +
//               "        <square style=\"solid\" width=\"5\" color=\"#E44234\" opacity=\"1\" creationdate=\"D:20200619203211Z\" flags=\"print\" date=\"D:20200619203211Z\" name=\"c684da06-12d2-4ccd-9361-0a1bf2e089e3\" page=\"1\" rect=\"113.312,277.056,235.43,350.173\" title=\"\" />\n" +
//               "      </add>\n" +
//               "      <modify />\n" +
//               "      <delete />\n" +
//               "      <pdf-info import-version=\"3\" version=\"2\" xmlns=\"http://www.pdftron.com/pdfinfo\" />\n" +
//               "    </xfdf>");
//     } on PlatformException catch (e) {
//       print("Failed to importAnnotationCommand '${e.message}'.");
//     }
//
//
//     try {
//       // Adds a bookmark into the document.
//       PdftronFlutter.importBookmarkJson('{"0":"Page 1"}');
//     } on PlatformException catch (e) {
//       print("Failed to importBookmarkJson '${e.message}'.");
//     }
//
//     // An event listener for when local annotation changes are committed to the document.
//     // xfdfCommand is the XFDF Command of the annotation that was last changed.
//     var annotCancel = startExportAnnotationCommandListener((xfdfCommand) {
//       String command = xfdfCommand;
//       print("flutter xfdfCommand:\n");
//       // Dart limits how many characters are printed onto the console.
//       // The code below ensures that all of the XFDF command is printed.
//       if (command.length > 1024) {
//         int start = 0;
//         int end = 1023;
//         while (end < command.length) {
//           print(command.substring(start, end) + "\n");
//           start += 1024;
//           end += 1024;
//         }
//         print(command.substring(start));
//       } else {
//         print("flutter xfdfCommand:\n $command");
//       }
//     });
//
//     // An event listener for when local bookmark changes are committed to the document.
//     // bookmarkJson is JSON string containing all the bookmarks that exist when the change was made.
//     var bookmarkCancel = startExportBookmarkListener((bookmarkJson) {
//       print("flutter bookmark: $bookmarkJson");
//     });
//
//     // To cancel event:
//     // annotCancel();
//     // bookmarkCancel();
//     // documentLoadedCancel();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         child:
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(onPressed: ()async{
//               await pickFile();
//               showViewer();
//               saveFile();
//             }, child: Text("Add a file")),
//
//             Container(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       onChanged: (text) {
//                         searchText = text;
//                       },
//                     ),
//                   ),
//                   ElevatedButton(onPressed: (){
//                     List<File> listOfPDFsHaveSameWord = [];
//
//                     //Here we start taking the search as a string and compare it with the strings in the PDF file
//                     for(int i = 0 ; i < listOfUsersPDF.length ; i++){
//                       //We take every file here as a document
//                       PdfDocument document =
//                       PdfDocument(inputBytes: File(listOfUsersPDF[i].path).readAsBytesSync());
//                       // here we extract every string inside the file and compare them
//                       List<MatchedItem> textCollection =
//                       PdfTextExtractor(document).findText([searchText]);
//                       if(textCollection.isNotEmpty){
//                         //Here we add all of the possible matched PDFs file to a list
//                         listOfPDFsHaveSameWord.add(listOfUsersPDF[i]);
//                       }
//                     }
//
//                     //Here we send all the PDFs founded to the search page to display results
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(listOfPDFsHaveSameWord,searchText)));
//
//
//                   }, child: Text("Search")),
//                 ],
//               ),
//             ),
//
//             Container(
//               width: double.infinity,
//               height: 600,
//               child: ListView(
//                   children: [
//                     for(int i = 0 ; i < listOfUsersPDF.length ; i++ )
//                       Container(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               GestureDetector(
//                                 child: Container(
//                                   padding: EdgeInsets.all(5),
//                                   width: 250,
//                                   height: 250,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey,
//                                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                                   ),
//                                   child: PdfDocumentLoader.openFile(
//                                       listOfUsersPDF[i].path,
//                                       pageNumber: 1,
//                                       pageBuilder: (context, textureBuilder, pageSize) => textureBuilder()
//                                   ),
//                                 ),
//                                 onTap: (){
//                                   PdftronFlutter.openDocument(listOfUsersPDF[i].path);
//                                 },
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(basename(listOfUsersPDF[i].path)),
//                               ),
//
//                             ],
//                           ),
//                         ),
//                       )
//                   ]
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
