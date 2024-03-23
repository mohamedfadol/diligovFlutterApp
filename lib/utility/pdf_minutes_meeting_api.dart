import 'dart:ui';

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
import '../models/attandence_board.dart';
import '../models/minutes_model.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../providers/localizations_provider.dart';

class PdfMinutesMeetingApi {
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

  static LocalizationsProvider getLocale(Context) {
    final providerLanguage =
        Provider.of<LocalizationsProvider>(Context, listen: false);
    return providerLanguage;
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

  static AppLocalizations? getLang(mat.BuildContext context) {
    return AppLocalizations.of(context);
  }


  static Future<File> generate(Minute minute, Context) async {
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

                logoWidgetTitle(minute),
                businessInformationWidgetTitle(minute, Context),
                pw.Divider(thickness: 1.0,),
                businessInformation(minute, Context),
                pw.Divider(thickness: 1.0,),
                pw.SizedBox(height: 2.0),
                pw.RichText(
                    text: pw.TextSpan(
                      text: '${getLang(Context)!.company_name} ${minute!.business!.businessName!} ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      children: [
                        pw.TextSpan(
                          text:
                              ' ${getLang(Context)!.minutes_of}  ${minute!.minuteName!} ${getLang(Context)!.committee} ',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        pw.TextSpan(
                            text:
                                '${minute!.minuteNumbers!}, ${getLang(Context)!.the_board_of_directors_of} ',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.normal)),
                        pw.TextSpan(
                            text: ' ${getLang(Context)!.held_on} ${minute!.minuteDate!} ',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.normal)),
                        pw.TextSpan(
                            text:
                                '( ${getLang(Context)!.where_meeting_through} ${minute!.meeting!.meetingMediaName!} )',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.normal)),
                      ],
                    ),
                    textDirection: getTextDirection(Context),
                    textAlign: getTextAlign(Context)
                ),
                pw.SizedBox(height: 15.0),
                pwTextBuildTitle(Context, getLang(Context)!.attendees , 8.0, pw.FontWeight.bold),
                meetingAttendanceBoardList(minute, Context),
                pw.SizedBox(height: 5.0),

                pwTextBuildTitle(Context, getLang(Context)!.meeting_agenda , 8.0, pw.FontWeight.bold),
                meetingAgendaList(minute, Context),
                pw.SizedBox(height: 5.0),
                buildDetailsOfMinutes(minute, Context),
                pw.SizedBox(height: 5.0),

                pwTextBuildTitle(Context, getLang(Context)!.details_of_agendas , 8.0, pw.FontWeight.bold),
                // pw.SizedBox(height: 1.0),
                agendaDetailsList(minute, Context),

                pw.SizedBox(height: 8.0),
                pwTextBuildTitle(Context, getLang(Context)!.documents_presented_at_the_meeting , 8.0, pw.FontWeight.bold),
                buildDocumentsPresentedAtTheMeeting(minute, Context),
                pw.SizedBox(height: 5.0),
                boardMembersDetails(minute, Context)
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
    return PDFApi.saveDocument(name: '${minute!.board!.boardName!}'+'${DateTime.now()}.pdf', pdf: pdf);
  }

  static pw.Widget boardMembersDetails(Minute minute, Context) {
    final members = minute!.board!.members!.map((member) {
      return member;
    }).toList();
    return pw.ListView(
        children: List.generate(
            members.length,
                (index) => pw.Column(
                mainAxisAlignment: getLocale(Context).locale.toString() == 'en' ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.end,
                children: [
                  pwTextBuildTitle(Context, '${members[index].position!.positionName} : ', 8.0, pw.FontWeight.bold),
                  pw.Row(
                      mainAxisAlignment: getLocale(Context).locale.toString() == 'en' ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.end,
                      children: [
                        pwTextExpandedBuildTitle(Context, '${members[index].memberFirstName} ${members[index].memberMiddelName} ${members[index].memberLastName}', 8.0, pw.FontWeight.bold, PdfColors.black),
                        pw.SizedBox(width: 1.0),
                        members[index]?.minuteSignature?.hasSigned != true ?  pwTextExpandedBuildTitle(Context, '......', 8.0, pw.FontWeight.bold, PdfColors.black)
                            : pw.Image(pw.MemoryImage((base64Decode(members[index]!.memberSignature!))),
                            fit: pw.BoxFit.contain,
                            height: 20,
                            width: 70,
                            alignment: pw.Alignment.center),
                      ]),
                  pw.SizedBox(height: 1.0)
                ]))
    );
  }

  static pw.Widget meetingAgendaList(Minute minute, Context) {
    final agendas = minute!.meeting!.agendas!.map((agenda) {
      return agenda;
    }).toList();
    return pw.Directionality(
        textDirection:  pw.TextDirection.rtl,
        child: pw.ListView(
            children: List.generate(
                agendas.length,
                (index) => pw.Column(
                        mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                            ? pw.MainAxisAlignment.start
                            : pw.MainAxisAlignment.end,
                        children: [
                          pw.SizedBox(height: 4.0),
                          pwTextBuildTitle(Context, '${index + 1} -  ${agendas[index].agendaTitle}', 8.0, pw.FontWeight.bold,),
                        ]
                )
            )
        ));
  }

  static pw.Widget meetingAttendanceBoardList(Minute minute, Context) {
    final attendanceBoards = minute!.attendanceBoards!.map((AttendanceBoard attendanceBoards) {
      return attendanceBoards;
    }).toList();
    return pw.ListView(
        children: List.generate(
            attendanceBoards.length,
            (index) => pw.Column(
                    mainAxisAlignment: getLocale(Context).locale.toString() == 'en' ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 4.0),
                      pw.Row(
                          mainAxisAlignment: getLocale(Context).toString() == 'en' ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.end,
                          children: [
                            pwTextExpandedBuildTitle(Context, '${index + 1} -  ${attendanceBoards[index].attendedName}', 7.0, pw.FontWeight.normal, PdfColors.black),
                            pw.SizedBox(width: 1.0),
                            pwTextExpandedBuildTitle(Context, '${getLang(Context)!.position} -  ${attendanceBoards[index].position}', 7.0, pw.FontWeight.normal, PdfColors.black),
                          ]),
                    ]
            )
        )
    );
  }

  static pw.Widget agendaDetailsList(Minute minute, Context) {
    final agendasDetails = minute!.meeting!.agendas!.map((agenda) {
      return pw.ListView(
          children: List.generate(
              agenda.agendaDetails!.length,
              (index) => pw.Column(
                      mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                          ? pw.MainAxisAlignment.start
                          : pw.MainAxisAlignment.end,
                      children: [
                          pw.SizedBox(height: 5.0),
                        pwTextBuildTitle(Context, '${index + 1} - ${agenda.agendaDetails![index].agenda!.agendaTitle} :', 8.0, pw.FontWeight.bold, ),
                        pwTextBuildTitle(Context, '${agenda.agendaDetails![index].missions}', 7.0, pw.FontWeight.normal, ),
                        pwTextBuildTitle(Context, '${agenda.agendaDetails![index].tasks}', 7.0, pw.FontWeight.normal, ),
                        pwTextBuildTitle(Context, '${agenda.agendaDetails![index].reservations}', 7.0, pw.FontWeight.normal, ),
                      ])));
    }).toList();

    return pw.Column(
        mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
            ? pw.MainAxisAlignment.start
            : pw.MainAxisAlignment.end,
        children: [...agendasDetails]);
  }

  static pw.Widget buildDocumentsPresentedAtTheMeeting(Minute minute, Context) {
    final agendas = minute!.meeting!.agendas!.map((agenda) {
      return agenda;
    }).toList();
    return pw.ListView(
        children: List.generate(
            agendas.length,
            (index) => pw.Column(
                    mainAxisAlignment: getLocale(Context).locale.toString() == 'en'
                        ? pw.MainAxisAlignment.start
                        : pw.MainAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 3.0),
                      pwTextBuildTitle(Context, '${agendas[index]?.agendaFile}' ?? '....', 7.0, pw.FontWeight.normal),
                      pw.SizedBox(height: 2.0)
                    ])));
  }

  static pw.Widget buildDetailsOfMinutes(Minute minute, Context) {
    final members = minute.board!.members!.map((member) => member).toList();
    final ceo = members.firstWhereOrNull((member) => member.position!.positionName == 'CEO');
    return pwTextExpandedBuildTitle(Context, '${getLang(Context)!.mr} ${ceo?.memberFirstName} ${ceo?.memberMiddelName} ${ceo?.memberLastName} – ${getLang(Context)!.chairman_of} ${minute.board!.boardName} ${getLang(Context)!.started_the_meeting_at} ${minute.meeting!.meetingStart}, ${getLang(Context)!.announced_the_quorum_approved_the_meeting_agenda}',
        8.0, pw.FontWeight.normal, PdfColors.black);
  }

  static pw.Widget logoWidgetTitle(Minute minute) => pw.Center(
        child: pw.Container(
            padding: const pw.EdgeInsets.all(10.0),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2.0, color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: minute!.business?.logo != null
                ? pw.Image(
                    pw.MemoryImage((base64Decode(minute!.business!.logo!))),
                    fit: pw.BoxFit.contain,
                    height: 20,
                    width: 70,
                    alignment: pw.Alignment.center)
                : pw.PdfLogo()),
      );

  static pw.Widget businessInformationWidgetTitle(Minute minute, Context) =>
        pw.Center(
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.SizedBox(height: 5.0),
                pwTextBuild(Context, '${minute.business!.businessName!}  ${minute.business?.businessDetails} ', 7.0, pw.FontWeight.normal, PdfColors.black),
                pwTextBuild(Context, '${getLang(Context)!.commercial_registration_no} ${minute.business?.registrationNumber} ', 7.0, pw.FontWeight.normal, PdfColors.black),
                pwTextBuild(Context, '${getLang(Context)!.capital} ${formatCurrency.format(minute.business?.capital)} ${getLang(Context)!.coin} ', 7.0, pw.FontWeight.normal, PdfColors.black),
              ]),
        );

  static pw.Widget logoWidget(Minute minute, Context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.blue))),
          child: pw.Row(
              children: [
            pw.PdfLogo(),
            pw.SizedBox(width: 0.8 * PdfPageFormat.mm),
            pwTextBuild(Context, minute.business!.businessName!, 15.0, pw.FontWeight.normal, (PdfColors.blue)!),
          ]
          ),
        );

  static pw.Widget businessInformation(Minute minute, Context) => pw.Container(
            child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                          pwTextExpandedBuildTitle(Context, "${getLang(Context)!.postal_code}: ${minute?.business?.postCode}", 7.0, pw.FontWeight.normal,PdfColors.black),
                          pw.SizedBox(width: 7.0),
                          pwTextExpandedBuildTitle(Context, "${getLang(Context)!.country}: ${minute?.business?.country}", 7.0, pw.FontWeight.normal,PdfColors.black),
                          pw.SizedBox(width: 7.0),
                          pwTextExpandedBuildTitle(Context, "${getLang(Context)!.phone_number}:  ${minute?.business?.mobile}", 7.0, pw.FontWeight.normal,PdfColors.black),
                          pw.SizedBox(width: 7.0),
                          pwTextExpandedBuildTitle(Context, "${getLang(Context)!.fax}: ${minute?.business?.fax}", 7.0, pw.FontWeight.normal,PdfColors.black),
                      ]));


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
