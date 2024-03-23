import 'package:flutter/services.dart';
import 'package:diligov/utility/pdf_api.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as mat;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/resolutions_model.dart';
import '../providers/localizations_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class PdfPragraphResolutionBoardApi {
    static NumberFormat formatCurrency = NumberFormat.simpleCurrency();

    static pw.TextDirection getTextDirection(context) {
      final pw.TextDirection? textDir;
      final providerLanguage =
      Provider.of<LocalizationsProvider>(context, listen: false);
      if (providerLanguage.locale.toString() == 'en') {
        textDir = pw.TextDirection.ltr;
      } else if (providerLanguage.locale.toString() == 'ar') {
        textDir = pw.TextDirection.rtl;
      } else {
        textDir = pw.TextDirection.ltr;
      }
      return textDir;
    }

    static pw.TextDirection getTextDirectionality(context) {
      final pw.TextDirection textDirLty;
      final providerLanguage =
      Provider.of<LocalizationsProvider>(context, listen: false);
      if (providerLanguage.locale.toString() == 'en') {
        textDirLty = pw.TextDirection.ltr;
      } else if (providerLanguage.locale.toString() == 'ar') {
        textDirLty = pw.TextDirection.rtl;
      } else {
        textDirLty = pw.TextDirection.ltr;
      }
      return textDirLty;
    }

    static LocalizationsProvider getLocale(context) {
      final providerLanguage =
      Provider.of<LocalizationsProvider>(context, listen: false);
      return providerLanguage;
    }

    static pw.TextAlign getTextAlign(context) {
      final pw.TextAlign? textAlig;
      final providerLanguage =
      Provider.of<LocalizationsProvider>(context, listen: false);
      if (providerLanguage.locale.toString() == 'en') {
        textAlig = pw.TextAlign.left;
      } else if (providerLanguage.locale.toString() == 'ar') {
        textAlig = pw.TextAlign.right;
      } else {
        textAlig = pw.TextAlign.left;
      }
      return textAlig;
    }

    static AppLocalizations? getLang(mat.BuildContext context) {
      return AppLocalizations.of(context);
    }

  static Future<File> generate(Resolution resolution, Context) async{
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf')),
    );
    pdf.addPage(
      pw.MultiPage(
          pageTheme: pw.PageTheme(
            textDirection: getTextDirection(Context),
            theme: theme,
            pageFormat: PdfPageFormat.a4,
          ),
          build: (pw.Context context) => <pw.Widget>[
            logoWidgetTitle(resolution),
            businessInformationWidgetTitle(resolution,Context),
            pw.Divider(thickness: 1.0,),
            businessInformation(resolution,Context),
            pw.Divider(thickness: 1.0,),
            pw.SizedBox(height: 2.0),

            pw.RichText(
              text: pw.TextSpan(text: '${getLang(Context)!.company_name} ${resolution!.business!.businessName!} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold,),
                children: [
                  pw.TextSpan(text: ' ${getLang(Context)!.board_resolution} ${resolution!.board!.boardName!} ${getLang(Context)!.no} ${resolution!.board?.serialNumber} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.normal,),),
                  pw.TextSpan(text: ' ${getLang(Context)!.on_day} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold,)),
                  pw.TextSpan(text: ' ${resolution?.resoultionDate}, ${getLang(Context)!.the_board_of_directors_of} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.normal)),
                  pw.TextSpan(text: ' ${resolution!.business!.businessName!} ,  ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: ' ${getLang(Context)!.has_resolved_the_following_by} , ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.normal)),
                  pw.TextSpan(text: ' ${getLang(Context)!.circulation} : , ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.normal)),
                  pw.TextSpan(text: ' ${getLang(Context)!.where_as}, ${resolution!.board!.boardName!} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: ' ${getLang(Context)!.resolved}, ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: ' ${resolution?.resoultionDecision} ',style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.normal)),
                ],
              ),
                textDirection: getTextDirection(Context),
                textAlign: getTextAlign(Context)
            ),
            pw.SizedBox(height: 20.0),
            boardMembersDetails(resolution,Context)
          ],
          footer: (context){
            final text = '${getLang(Context)!.page} ${context.pageNumber} ${getLang(Context)!.sign_of} ${context.pagesCount}';
            return pw.Column(
                mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                    ? pw.MainAxisAlignment.start
                    : pw.MainAxisAlignment.end,
              children: [
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pwTextExpandedWithIContainerBuildTitle(Context, '${getLang(Context)!.board_resolution} ${resolution!.board!.boardName!} ${getLang(Context)!.date} ${resolution!.board!.term!} ${getLang(Context)!.number}'
                          ,8.0,pw.FontWeight.bold,),
                      pwTextExpandedWithIContainerBuildTitle(Context, text,8.0,pw.FontWeight.bold),
                    ]
                )
              ]
            );
          }
      ),
    );
    return PDFApi.saveDocument(name: '${resolution.board!.boardName!}.pdf', pdf: pdf);
  }

static pw.Widget boardMembersDetails(Resolution resolution, Context) {
    final members = resolution.board!.members!.map((member){return member;}).toList();
    return pw.ListView (
      children: List.generate( 
          members.length, (index) => pw.Column(
          mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
              ? pw.MainAxisAlignment.start
              : pw.MainAxisAlignment.end,
        children: [
          pwTextBuildTitle(Context, '${members[index].position!.positionName} :', 8.0, pw.FontWeight.bold, ),
          pw.Row(
          mainAxisAlignment: getLocale(Context).toString() == 'en' ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.end,
            children: [
              pwTextExpandedBuildTitle(Context, '${members[index].memberFirstName} ${members[index].memberMiddelName} ${members[index].memberLastName}', 7.0,
                  pw.FontWeight.normal, PdfColors.black),
              pw.SizedBox(width: 1.0),
              members[index]?.signature?.hasSigned != true ? pwTextExpandedBuildTitle(Context, '.......................', 7.0, pw.FontWeight.normal, PdfColors.black)
              : pw.Image(pw.MemoryImage((base64Decode(members[index]!.memberSignature!))),fit: pw.BoxFit.contain,height: 20,width: 70,alignment: pw.Alignment.center),
            ]
          ),
          pw.SizedBox(height: 1.0)
        ]
      )
      )
    );
}


static pw.Widget logoWidgetTitle(Resolution resolution) => pw.Center(
    child: pw.Container(
        padding: const pw.EdgeInsets.all(10.0),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            width: 2.0,
              color: PdfColors.grey
          ),
          borderRadius: pw.BorderRadius.circular(10),
        ),
      child: resolution!.business?.logo != null
          ? pw.Image(pw.MemoryImage((base64Decode(resolution!.business!.logo!))),
          fit: pw.BoxFit.contain,height: 20,width: 70,alignment: pw.Alignment.center)
          : pw.PdfLogo()
    ),
  );

static pw.Widget businessInformationWidgetTitle(Resolution resolution,Context) => pw.Center(
    child: pw.Column(
        children: [
          pw.SizedBox(height: 5.0),
          pwTextBuild(Context, '${resolution.business!.businessName!} ${resolution.business!.businessDetails!},', 7.0, pw.FontWeight.normal, PdfColors.black),
          pwTextBuild(Context, '${getLang(Context)!.commercial_registration_no} ${resolution.business?.registrationNumber},', 7.0, pw.FontWeight.normal, PdfColors.black),
          pwTextBuild(Context, '${getLang(Context)!.capital} ${resolution.business?.capital} ${getLang(Context)!.coin}', 7.0, pw.FontWeight.normal, PdfColors.black),
        ]
    ),
  );

static pw.Widget logoWidget(Resolution resolution, context) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
    decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2,color: PdfColors.blue))
    ),
    child: pw.Row(
        children: [
          pw.PdfLogo(),
          pw.SizedBox(width: 0.8 * PdfPageFormat.mm),
          pwTextBuild(context, resolution.business!.businessName!, 15.0, pw.FontWeight.normal, (PdfColors.blue)!),
        ]
    ),
  );

static pw.Widget businessInformation(Resolution resolution ,context) => pw.Container(
      child: pw.Container(
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                  pwTextExpandedBuildTitle(context, "${getLang(context)!.postal_code}: ${resolution?.business?.postCode}", 7.0, pw.FontWeight.normal,PdfColors.black),
                  pw.SizedBox(width: 7.0),
                  pwTextExpandedBuildTitle(context, "${getLang(context)!.country}: ${resolution?.business?.country}", 7.0, pw.FontWeight.normal,PdfColors.black),
                  pw.SizedBox(width: 7.0),
                  pwTextExpandedBuildTitle(context, "${getLang(context)!.phone_number}:  ${resolution?.business?.mobile}", 7.0, pw.FontWeight.normal,PdfColors.black),
                  pw.SizedBox(width: 7.0),
                  pwTextExpandedBuildTitle(context, "${getLang(context)!.fax}: ${resolution?.business?.fax}", 7.0, pw.FontWeight.normal,PdfColors.black),
              ]
          )
      )
  );





static pw.Row pwTextBuildTitle(mat.BuildContext context, String title,double fontSize,pw.FontWeight fontWeight) {
  return pw.Row(children: [
    pw.Expanded(
        child: pw.Directionality(
          textDirection: getTextDirectionality(context),
          child: pw.Text(title,
              style: pw.TextStyle(fontSize: fontSize, fontWeight: fontWeight),textDirection: getTextDirection(context),textAlign: getTextAlign(context)),
        )
    )
  ]);
}

static pw.Expanded pwTextExpandedWithIContainerBuildTitle(mat.BuildContext context, String title,double fontSize,pw.FontWeight fontWeight) {
  return pw.Expanded(
      child: pw.Directionality(
          textDirection: getTextDirectionality(context),
          child: pw.Container(
            margin: const pw.EdgeInsets.only(top: 1 * PdfPageFormat.cm),
            child: pw.Text(title, style: pw.TextStyle(fontSize: fontSize, fontWeight: fontWeight),textDirection: getTextDirection(context),textAlign: getTextAlign(context)),
          )
      )
  );
}

static pw.Expanded pwTextExpandedBuildTitle(mat.BuildContext context, String title,double fontSize,pw.FontWeight fontWeight,PdfColor? color) {
  return pw.Expanded(
      child: pw.Directionality(
        textDirection: getTextDirectionality(context),
        child:  pw.Text(title, style: pw.TextStyle(fontSize: fontSize, fontWeight: fontWeight,color: color),textDirection: getTextDirection(context),textAlign: getTextAlign(context)),
      )
  );
}

static pw.Directionality pwTextBuild(mat.BuildContext context, String title,double fontSize,pw.FontWeight fontWeight,PdfColor? color) {
      return  pw.Directionality(
        textDirection: getTextDirectionality(context),
        child:  pw.Text(title, style:
        pw.TextStyle(fontSize: fontSize, fontWeight: fontWeight,color: color),textDirection: getTextDirection(context),textAlign: getTextAlign(context)),
      );
    }
}