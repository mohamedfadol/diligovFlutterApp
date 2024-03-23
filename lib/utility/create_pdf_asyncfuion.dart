import 'dart:io';
import 'dart:ui';

import 'package:diligov/utility/pdf_api.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/resolutions_model.dart';
class NewPdf{

  static Future<File> createPDF(Resolution resolution) async {
    //Create a new PDF document
    PdfDocument document = PdfDocument();
    //Adds a page to the document
    PdfPage page = document.pages.add();
    final pageSize = page.getClientSize();


    //Create a PdfGrid class
    PdfGrid grid = PdfGrid();
    //Add the columns to the grid
    grid.columns.add(count: 4);
    //Add header to the grid
    grid.headers.add(1);

    //Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Postl Code: ${resolution?.business?.postCode}';
    header.cells[1].value = 'Country: ${resolution?.business?.country}';
    header.cells[2].value = 'Phone Number:  ${resolution?.business?.mobile}';
    header.cells[3].value = 'Fax: ${resolution?.business?.fax}';

    //Set the grid style
    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 1, top: 1, bottom: 1),
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 12));
    //Draw the grid
    grid.draw(page: page, bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height));

    //Create a PDF page template and add header content.
    final PdfPageTemplateElement headerTemplate = PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
    //Draw text in the header.
    // page.graphics.drawLine(PdfPen(PdfColor(255, 0, 0), width: 5),const Offset(0, 500,),const Offset(10, 200));
    headerTemplate.graphics.drawString('This is page header', PdfStandardFont(PdfFontFamily.helvetica, 4),bounds:   Rect.fromLTWH(200, 5, page.getClientSize().width, 20));
    //Add the header element to the document.
    document.template.top = headerTemplate;

   final text = ''' 
                Company Name ${resolution!.business!.businessName!}...
                Board Resolution ${resolution!.board!.boardName!} No 12:246:55
                Board Resolution ${resolution!.board!.boardName!} No 12:246:55
                On DAY, ${resolution?.resoultionDate}, the Board of Directors of
                ${resolution!.business!.businessName!} , has resolved the following by
                WHERE AS, ${resolution!.board!.boardName!}
                circulation :
                Brief on Matter
                RESOLVED, to approve ${resolution?.resoultionDecision}
                ''';
    //Load the paragraph text into PdfTextElement with standard font
    PdfTextElement textElement = PdfTextElement(text:text,font: PdfStandardFont(PdfFontFamily.helvetica, 8),);
    //Draw the paragraph text on page and maintain the position in PdfLayoutResult
    PdfLayoutResult layoutResult = textElement.draw(page: page,bounds: Rect.fromLTWH(0, 50, page.getClientSize().width,page.getClientSize().height))!;

    //Assign standard font to PdfTextElement
    textElement.font = PdfStandardFont(PdfFontFamily.helvetica, 12,style: PdfFontStyle.bold);
    //Draw the header text on page, below the paragraph text with a height gap of 20 and maintain the position in PdfLayoutResult
    // layoutResult = textElement.draw(page: page,bounds: Rect.fromLTWH(0, layoutResult.bounds.bottom + 12, 0, 0))!;





    // //Draw the image
    for(int i =0;i < resolution!.board!.members!.length ; i++){
      final members = resolution!.board!.members!.map((member) => member).toList();

      page.graphics.drawString('${members[i]?.memberFirstName} ${members[i]?.memberMiddelName} ${members[i]?.memberLastName}', PdfStandardFont(PdfFontFamily.helvetica, 10),
          brush: PdfSolidBrush(PdfColor(0, 0, 0)),
          bounds:  Rect.fromLTWH(0, 150, pageSize.width, 50));

      // //Read the image data from the weblink.
      // var imageLoad = members[i]!.memberSignature ?? 'member_signature_1677251632_.png';
      // var url ="https://diligov.com/public/signatures/$imageLoad";
      // print(url);
      // var response = await get(Uri.parse(url));
      // var data = response.bodyBytes;
      // //Create a bitmap object.
      // PdfBitmap image = PdfBitmap(data);
      // //Draw an image to the document.
      // page.graphics.drawImage(image, const Rect.fromLTWH( 150, 150,  50, 20));
      //

    }

    //Create a PDF page template and add footer content.
    final PdfPageTemplateElement footerTemplate = PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
    //Draw text in the footer.
    footerTemplate.graphics.drawString('Board Resolution ${resolution!.board!.boardName!}  Date ${resolution?.resoultionDate}',
        PdfStandardFont(PdfFontFamily.helvetica, 6),bounds: Rect.fromLTWH(0, 15, page.getClientSize().width, 20));
    //Set footer in the document.
    document.template.bottom = footerTemplate;

    return PDFApi.saveDocumentAsyncFusion(name: '${resolution!.board!.boardName!}.pdf', pdf: document);
  }




}