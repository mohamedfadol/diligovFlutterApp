import 'package:flutter/services.dart';
import 'package:diligov/utility/pdf_api.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import '../models/board_model.dart';
class PdfPragraphApi {

  static Future<File> generate(Board board) async{
    final pdf = Document();
    final theme = ThemeData.withFont(
      base: Font.ttf(await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf')),
      bold: Font.ttf(await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf')),
    );
    double textFontSize = 7.0;
    pdf.addPage(
      MultiPage(
          pageTheme: PageTheme(
            theme: theme,
            pageFormat: PdfPageFormat.a4,
          ),
          build: (context) => <Widget>[
            logoWidget(board),
            businessInformations(board),
            Text('Company Name ${board!.business!.businessName!}...',style: TextStyle(color: PdfColors.grey,fontSize: 10)),
            Text('Board Resolution ${board.boardName!} No 12:246:55',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('On DAY, 00/00/0000, the Board of Directors of',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('${board!.business!.businessName!} , has resolved the following by',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('circulation :',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('WHERE AS,',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('Brief on Matter',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('RESOLVED, to approve',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),

      ],
      footer: (context){
            final text = 'Page ${context.pageNumber} of ${context.pagesCount}';
            return Row(
              children: [
                Text('Board Resolution ${board.boardName!} Date ${board.term!} Number',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 1 * PdfPageFormat.cm),
                  child: Text(text,style: TextStyle(color: PdfColors.black)),
                )
              ]
            );
    }
      ),
    );
    return PDFApi.saveDocument(name: '${board.boardName!}.pdf', pdf: pdf);
  }

  static Widget logoWidget(Board board) => Container(
        padding: EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2,color: PdfColors.blue))
        ),
      child: Row(
        children: [
          PdfLogo(),
          SizedBox(width: 0.8 * PdfPageFormat.mm),
          Text("${board!.business!.businessName!}",style: TextStyle(fontSize: 15, color: PdfColors.blue))
        ]
      ),
  );

  static Widget businessInformations(Board board) => Header(
    child: Container(
            padding: EdgeInsets.only(top: 2 * PdfPageFormat.mm,bottom: 2 * PdfPageFormat.mm),
            decoration: BoxDecoration(
              color: PdfColors.red
            ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Postl Code: ${board?.business?.postCode}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
              SizedBox(width:7.0),
              Text("Country: ${board?.business?.country}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
              SizedBox(width:7.0),
              Text("Phone Number:  ${board?.business?.mobile}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
              SizedBox(width:7.0),
              Text("Fax: ${board?.business?.fax}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
            ]
        )
    )
  );


}