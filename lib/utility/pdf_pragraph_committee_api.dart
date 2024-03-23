import 'package:flutter/services.dart';
import 'package:diligov/utility/pdf_api.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import '../models/committee_model.dart';
class PdfPragraphCommitteeApi {

  static Future<File> generate(Committee committee) async{
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
            logoWidget(committee),
            businessInformations(committee),
            Text('Company Name ${committee.business!.businessName!}...',style: TextStyle(color: PdfColors.grey,fontSize: 10)),
            Text('Committee Resolution ${committee.committeeName!} No 12:246:55',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('On DAY, 00/00/0000, the Members of',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('${committee.business!.businessName!} , has resolved the following by',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('circulation :',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('WHERE AS,',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('Brief on Matter',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            Text('RESOLVED, to approve',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
            SizedBox(height: 10),
            fetchMembers(committee),
          ],
          footer: (context){
            final text = 'Page ${context.pageNumber} of ${context.pagesCount}';
            return Row(
                children: [
                  Text('Committee Resolution ${committee.committeeName!} Date ${committee!.board!.boardName!} Number',style: TextStyle(color: PdfColors.grey,fontSize: textFontSize)),
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
    return PDFApi.saveDocument(name: '${committee!.committeeName!}.pdf', pdf: pdf);
  }
  static Widget fetchMembers(Committee committee) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for(var member in committee.members!)
          Text("Member of ${member.memberFirstName} ${member.memberLastName} Committee",style: TextStyle(color: PdfColors.grey,fontSize: 5)),
          Text("Members Signature ................",style: TextStyle(color: PdfColors.grey,fontSize: 5)),

        ]
    );
  }

  static Widget fetchMembers2(Committee committee) {
  return Column(
      children: <Widget>[
        // note the ... spread operator that enables us to add two elements
        for (int i = 0; i < committee.members!.length; i++) ...[
          Text("Member of ${committee.members![i].memberFirstName} ${committee.members![i].memberLastName} Committee",
              style: TextStyle(color: PdfColors.grey,fontSize: 5)),
          Column(
            children: <Widget>[
              // this creates scat.length many elements inside the Column
              for (int j = 0; j < committee.members!.length; j++)
                Text("jjd")
            ],
          )
        ]
      ]
  );


  }

  static Widget logoWidget(Committee committee) => Container(
    padding: EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 2,color: PdfColors.blue))
    ),
    child: Row(
        children: [
          PdfLogo(),
          SizedBox(width: 0.8 * PdfPageFormat.mm),
          Text("${committee.business!.businessName!}",style: TextStyle(fontSize: 15, color: PdfColors.blue))
        ]
    ),
  );

  static Widget businessInformations(Committee committee) => Header(
      child: Container(
          padding: EdgeInsets.only(top: 2 * PdfPageFormat.mm,bottom: 2 * PdfPageFormat.mm),
          decoration: BoxDecoration(
              color: PdfColors.red
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Postl Code: ${committee.business?.postCode}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
                SizedBox(width:7.0),
                Text("Country: ${committee.business?.country}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
                SizedBox(width:7.0),
                Text("Phone Number:  ${committee.business?.mobile}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
                SizedBox(width:7.0),
                Text("Fax: ${committee.business?.fax}",style: TextStyle(color: PdfColors.white,fontSize: 5,fontWeight: FontWeight.normal)),
              ]
          )
      )
  );


}