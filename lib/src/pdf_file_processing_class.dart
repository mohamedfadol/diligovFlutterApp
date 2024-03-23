import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../utility/pdf_api.dart';
class PdfFileProcessingClass{

  static Future<File?> ReplaceImageByIndexOfPageFromNetWorkPath(String imagePath, int replacePageIndex, int totalPagesOfFile,String fileFromNetWorkPath) async {
    try{
    //   final ByteData data = await rootBundle.load(fileFromNetWorkPath!);
      // final Uint8List bytes = data.buffer.asUint8List();
          final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
          final downloadFileToLocal = await downloadFile(fileFromNetWorkPath!, '$fileCreateTime+new.pdf');
          final Uint8List bytes = downloadFileToLocal.readAsBytesSync().buffer.asUint8List();
          final pdf_render.PdfDocument document = await pdf_render.PdfDocument.openData(bytes!);
          final pdf = pw.Document();
          for (int i = 0; i < totalPagesOfFile; i++) {
            print("total of pages in === $totalPagesOfFile");
            if (i == replacePageIndex) {
              final editImagePage = pw.MemoryImage(File(imagePath!).readAsBytesSync());
              pdf.addPage(pw.Page(build: (pw.Context context) {return pw.Center(child: pw.Image(editImagePage));}));
            } else {
              final pdf_render.PdfPage page = await document.getPage(i+1);
              final pdf_render.PdfPageImage pageImage = await page.render(fullHeight: page.height, fullWidth: page.width ,backgroundFill: true);
              ui.Image imageCreatedFromRestPdfPages = await  pageImage.createImageDetached();
              ByteData? byteData = await imageCreatedFromRestPdfPages.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData!.buffer.asUint8List();
              final directory = await getTemporaryDirectory();
              final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
              final imageNewPath = await File('${directory.path}/$fileCreateTime.png').create();
              await imageNewPath.writeAsBytes(pngBytes);
              final createdNewImage = pw.MemoryImage(File(imageNewPath.path!).readAsBytesSync());
              pdf.addPage(pw.Page(build: (pw.Context context) {return pw.Center(child: pw.Image(createdNewImage),);},));
            }
          }
          print("file done in create Pdf Replace Image ByIndexOfPage From NetWork Path function done");
      return PDFApi.saveDocument(name: '${DateTime.now().millisecondsSinceEpoch}+nnn.pdf', pdf: pdf!);
    } catch (e) {
      print("Error in create Pdf Replace Image ByIndexOfPage From NetWork Path function: $e");
      return null;
    }
  }



  static Future<File> downloadFile(String url, String fileName) async {
    // Find a directory to save the downloaded file
    Directory directory = await getApplicationDocumentsDirectory();
    // Create the full path to save the file
    String filePath = path.join(directory.path!, fileName);
    // Download the file
    http.Response response = await http.get(Uri.parse(url));
    // Write the file
    File file = File(filePath!);
    return await file.writeAsBytes(response.bodyBytes);
  }

}