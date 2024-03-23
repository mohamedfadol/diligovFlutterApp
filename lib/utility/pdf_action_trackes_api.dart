import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:diligov/utility/pdf_api.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as mat;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../models/action_tracker_model.dart';
import '../providers/localizations_provider.dart';
class PdfActionTrackesAPI {

  static NumberFormat formatCurrency = NumberFormat.simpleCurrency();

  static pw.TextDirection getTextDirection(Context) {
    final pw.TextDirection? textDir;
    final providerLanguage =
        Provider.of<LocalizationsProvider>(Context, listen: false);
    if (providerLanguage.locale.toString() == 'en') {
      textDir = pw.TextDirection.ltr;
    } else if (providerLanguage.locale.toString() == 'ar') {
      textDir = pw.TextDirection.rtl;
    } else {
      textDir = pw.TextDirection.ltr;
    }
    return textDir;
  }

  static pw.TextDirection getTextDirectionality(Context) {
    final pw.TextDirection textDirLty;
    final providerLanguage =
        Provider.of<LocalizationsProvider>(Context, listen: false);
    if (providerLanguage.locale.toString() == 'en') {
      textDirLty = pw.TextDirection.ltr;
    } else if (providerLanguage.locale.toString() == 'ar') {
      textDirLty = pw.TextDirection.rtl;
    } else {
      textDirLty = pw.TextDirection.ltr;
    }
    return textDirLty;
  }

  static pw.TextAlign getTextAlign(Context) {
    final pw.TextAlign? textAlig;
    final providerLanguage =
        Provider.of<LocalizationsProvider>(Context, listen: false);
    if (providerLanguage.locale.toString() == 'en') {
      textAlig = pw.TextAlign.left;
    } else if (providerLanguage.locale.toString() == 'ar') {
      textAlig = pw.TextAlign.right;
    } else {
      textAlig = pw.TextAlign.left;
    }
    return textAlig;
  }


  static LocalizationsProvider getLocale(Context) {
    final providerLanguage =
        Provider.of<LocalizationsProvider>(Context, listen: false);
    return providerLanguage;
  }

 static AppLocalizations? getLang(mat.BuildContext context) {
    return AppLocalizations.of(context);
  }


  static Future<File> generate(List<ActionTracker>? actionstrackers, Context) async {
    final pw.Document pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf')),
      bold: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf')),
    );
    pdf.addPage(
      pw.MultiPage(
          pageTheme: pw.PageTheme(
            textDirection: getTextDirection(Context),
            theme: theme,
            pageFormat: PdfPageFormat.a4,
          ),
          build: (pw.Context context) => <pw.Widget>[
                logoWidgetTitle(actionstrackers),
                businessInformationWidgetTitle(actionstrackers, Context),
                pw.Divider(thickness: 1.0,),
                businessInformation(actionstrackers, Context),
                pw.Divider(thickness: 1.0,),
                pw.SizedBox(height: 2.0),
            buildHeaderTable(actionstrackers)

              ],
          footer: (context) {
            final text =
                '${getLang(Context)!.page} ${context.pageNumber} ${getLang(Context)!.sign_of} ${context.pagesCount}';
            return pw.Column(
                mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                    ? pw.MainAxisAlignment.start
                    : pw.MainAxisAlignment.end,
                children: [
                  pw.Divider(),
                  pw.Row(
                      mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                          ? pw.MainAxisAlignment.start
                          : pw.MainAxisAlignment.end,
                      children: [
                        pwTextExpandedWithIContainerBuildTitle(Context, text,8.0,pw.FontWeight.bold),
                      ])
                ]);
          }),
    );
    return PDFApi.saveDocument(name: 'mohameb'+'${DateTime.now()}.pdf', pdf: pdf);
  }



  static pw.Widget buildHeaderTable(List<ActionTracker>? actionsTracker){
      final headers = [
        'Task name',
        'Date assigned',
        'Due date',
        'Owner',
        'Meeting name',
        'Status',
        'Note',
      ];
      final data = actionsTracker!.map((action) {
        return [
          action.actionsTasks,
          action.actionsDateAssigned,
          action.actionsDateDue,
          action.member?.position?.positionName ?? 'Not assigned for member',
          action.meeting?.meetingTitle ?? 'Not assigned for meeting',
          action.actionStatus,
          action.actionNote ?? 'Not fill note',
        ];
      }).toList();
      return pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(width: 1.0),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.0, color: PdfColors.black),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey400),
          cellHeight: 20,
          cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.centerLeft,
          4: pw.Alignment.centerLeft,
          5: pw.Alignment.centerLeft,
        },
          headerAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
            3: pw.Alignment.centerLeft,
            4: pw.Alignment.center,
            5: pw.Alignment.centerLeft,
          },
          cellStyle:  pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 7.0),
          rowDecoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5)
            )
      );
  }

  static pw.Widget logoWidgetTitle(List<ActionTracker>? actionstrackers) {
    final business = actionstrackers!.first?.business;
    return pw.Center(
      child: pw.Container(
          padding: const pw.EdgeInsets.all(10.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2.0, color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: business?.logo != null
              ? pw.Image(
              pw.MemoryImage((base64Decode(business!.logo!))),
              fit: pw.BoxFit.contain,
              height: 20,
              width: 70,
              alignment: pw.Alignment.center)
              : pw.PdfLogo()),
    );
  }

  static pw.Widget businessInformationWidgetTitle(List<ActionTracker>? actionstrackers, Context) {
    final business = actionstrackers!.first!.business!;
    return pw.Center(
      child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.SizedBox(height: 5.0),
            pwTextBuild(Context, '${business!.businessName!}  ${business?.businessDetails != null ? business?.businessDetails : ""} ', 7.0, pw.FontWeight.normal, PdfColors.black),
            pwTextBuild(Context, '${getLang(Context)!.commercial_registration_no} ${business?.registrationNumber} ', 7.0, pw.FontWeight.normal, PdfColors.black),
            pwTextBuild(Context, '${getLang(Context)!.capital} ${formatCurrency.format(business?.capital)} ${getLang(Context)!.coin} ', 7.0, pw.FontWeight.normal, PdfColors.black),
          ]),
    );
  }


  static pw.Widget logoWidget(List<ActionTracker>? actionstrackers, Context) {
    final business = actionstrackers!.first!.business!;
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(width: 2, color: PdfColors.blue))),
      child: pw.Row(
          children: [
            pw.PdfLogo(),
            pw.SizedBox(width: 0.8 * PdfPageFormat.mm),
            pwTextBuild(Context, business!.businessName!, 15.0, pw.FontWeight.normal, (PdfColors.blue)!),
          ]
      ),
    );
  }

  static pw.Widget businessInformation(List<ActionTracker>? actionstrackers, Context) {
    final business = actionstrackers!.first!.business!;
    return pw.Container(
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pwTextExpandedBuildTitle(Context, "${getLang(Context)!.postal_code}: ${business?.postCode}", 7.0, pw.FontWeight.normal,PdfColors.black),
              pw.SizedBox(width: 7.0),
              pwTextExpandedBuildTitle(Context, "${getLang(Context)!.country}: ${business?.country}", 7.0, pw.FontWeight.normal,PdfColors.black),
              pw.SizedBox(width: 7.0),
              pwTextExpandedBuildTitle(Context, "${getLang(Context)!.phone_number}:  ${business?.mobile}", 7.0, pw.FontWeight.normal,PdfColors.black),
              pw.SizedBox(width: 7.0),
              pwTextExpandedBuildTitle(Context, "${getLang(Context)!.fax}: ${business?.fax}", 7.0, pw.FontWeight.normal,PdfColors.black),
            ])
    );
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