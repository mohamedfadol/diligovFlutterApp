import 'dart:convert';
import 'dart:io';

import 'package:diligov/models/financial_model.dart';
import 'package:diligov/widgets/appBar.dart';
import 'package:diligov/widgets/custom_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../models/meeting_model.dart';
import '../../../models/user.dart';
import '../../../providers/financial_page_provider.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_financial_api.dart';
import '../../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/date_format_text_form_field.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../../widgets/stand_text_form_field.dart';
import '../meetings/show_meeting.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';

class FinancialListViews extends StatefulWidget {
  const FinancialListViews({super.key});
  static const routeName = '/FinancialListViews';
  @override
  State<FinancialListViews> createState() => _FinancialListViewsState();
}

class _FinancialListViewsState extends State<FinancialListViews> {
  final insertFinancialFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  // Initial Selected Value
  String yearSelected = '2023';
  late String _business_id;
  String? _fileBase64;
  String? _fileName;
  FilePickerResult? result;
  String? _fileNameNew;
  PlatformFile? pickedFiles;
  void pickedFile() async {
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        _fileNameNew = result!.files.first.name;
        pickedFiles = result!.files.first;
        _fileName = pickedFiles!.path!;
        print("file name $_fileNameNew");
        print("file pickedFiles with path $_fileName");
      }
    } catch (e) {
      print(e);
    }
  }

  TextEditingController financialName = TextEditingController();
  TextEditingController financialDate = TextEditingController();
  TextEditingController financialFile = TextEditingController();
  late FinancialPageProvider providerFinancial;

  Meetings? _listOfMeetingsData;
  String? meeting_id = "";
  Future getListMeetings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler
        .get('/get-list-meetings/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      setState(() {
        _listOfMeetingsData = Meetings.fromJson(meetingsData);
      });
    } else {
      log.d("get-list-meetings response statusCode unknown");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      yearSelected = '2023';
      getListMeetings();
      providerFinancial = Provider.of<FinancialPageProvider>(context,listen: false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    financialName.dispose();
    financialDate.dispose();
    financialFile.dispose();
    pickedFiles = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await openFinancialCreateDialog();
        },
        child: CustomIcon(
          icon: Icons.add,
          size: 30.0,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(),
              Center(
                child: Consumer<FinancialPageProvider>(
                    builder: (context, provider, child) {
                  if (provider.financialData?.financials == null) {
                    provider.getListOfFinancials(context);
                    return buildLoadingSniper();
                  }
                  return provider.financialData!.financials!.isEmpty
                      ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              showBottomBorder: true,
                              dividerThickness: 5.0,
                              headingRowColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Colour().darkHeadingColumnDataTables),
                              // dataRowColor: MaterialStateColor.resolveWith((states) => Colour().lightBackgroundColor),
                              columns: <DataColumn>[
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!
                                          .minute_name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show minute name"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.date,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show minute Date"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.file,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "file"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!
                                          .meeting_name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "meeting name"),
                                DataColumn(
                                    label: CustomText(
                                      text:
                                          AppLocalizations.of(context)!.signed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "signed"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.owner,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "owner that add by"),
                                DataColumn(
                                    label: CustomText(
                                      text:
                                          AppLocalizations.of(context)!.actions,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip:
                                        "show buttons for functionality members"),
                              ],
                              rows: provider!.financialData!.financials!
                                  .map((FinancialModel financial) =>
                                      DataRow(cells: [
                                        BuildDynamicDataCell(
                                          child: CustomText(text:financial!.financialName!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        BuildDynamicDataCell(
                                          child: CustomText(text:financial!.financialDate!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        BuildDynamicDataCell(
                                          child: TextButton(
                                              onPressed: () async {
                                                var businessName = financial!.business!.businessId!;
                                                String charterName = financial!.financialFile!;
                                                String url = "https://diligov.com/public/charters/financials/$charterName";
                                                print(url);
                                                // openPDF(context,url,charterName);
                                              },
                                              child: CustomText(text:financial?.meeting?.meetingFile ??'Show File', fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,maxLines: 1,overflow: TextOverflow.ellipsis,
                                              )),
                                        ),

                                        BuildDynamicDataCell(
                                          child: financial.meeting?.agendas?.length == null
                                              ? CustomText(text:'Meeting agenda not found',fontWeight: FontWeight.bold,fontSize: 14.0,)
                                              : TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowMeeting(meeting: financial.meeting!,)));
                                              },
                                              child: CustomText(text:financial?.meeting?.meetingTitle ??'Circular',fontWeight: FontWeight.bold,fontSize: 14.0,)
                                          ),
                                        ),
                                        BuildDynamicDataCell(
                                          child: CustomText(text:financial!.financialName!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        BuildDynamicDataCell(
                                          child: CustomText(text:financial?.user?.firstName ??"loading ...",
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                         DataCell(
                                          PopupMenuButton<int>(
                                              padding:
                                                  EdgeInsets.only(bottom: 5.0),
                                              icon: CustomIcon(
                                                icon: Icons.settings,
                                                size: 30.0,
                                              ),
                                              onSelected: (value) => 0,
                                              itemBuilder: (context) => [
                                                    PopupMenuItem<int>(
                                                        value: 0,
                                                        child:
                                                            CustomElevatedButton(
                                                                verticalPadding:
                                                                    0.0,
                                                                text: AppLocalizations
                                                                        .of(
                                                                            context)!
                                                                    .view,
                                                                icon: Icons
                                                                    .remove_red_eye_outlined,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                buttonBackgroundColor:
                                                                    Colors.red,
                                                                horizontalPadding:
                                                                    10.0,
                                                                callFunction:
                                                                    () async {
                                                                      print('View done');
                                                                      final pdfFile = await PdfFinancialApi.generate(financial,context);
                                                                      print(pdfFile);
                                                                      PDFApi.openFile(pdfFile);
                                                                })),
                                                    PopupMenuItem<int>(
                                                        value: 1,
                                                        child: CustomElevatedButton(
                                                            verticalPadding:
                                                                0.0,
                                                            text:
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .export,
                                                            icon: Icons
                                                                .import_export_outlined,
                                                            textColor:
                                                                Colors.white,
                                                            buttonBackgroundColor:
                                                                Colors.red,
                                                            horizontalPadding:
                                                                10.0,
                                                            callFunction:
                                                                () async {
                                                              await dialogDownloadFinancial(financial);
                                                                })),
                                                    PopupMenuItem<int>(
                                                        value: 2,
                                                        child: CustomElevatedButton(
                                                            verticalPadding:
                                                                0.0,
                                                            text:
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .signed,
                                                            icon: Icons
                                                                .checklist_outlined,
                                                            textColor:
                                                                Colors.white,
                                                            buttonBackgroundColor:
                                                                Colors.red,
                                                            horizontalPadding:
                                                                10.0,
                                                            callFunction:() { dialogToMakeSignFinancial(financial);})),
                                                    PopupMenuItem<int>(
                                                        value: 4,
                                                        child:
                                                            CustomElevatedButton(
                                                          verticalPadding: 0.0,
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .delete,
                                                          icon: Icons
                                                              .restore_from_trash_outlined,
                                                          textColor:
                                                              Colors.white,
                                                          buttonBackgroundColor:
                                                              Colors.red,
                                                          horizontalPadding:
                                                              10.0,
                                                          callFunction: () {
                                                            dialogDeleteFinancial(financial);
                                                          },
                                                        )),
                                                  ]),
                                        ),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFullTopFilter() => Padding(
        padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 15.0),
                color: Colors.red,
                child: CustomText(
                    text: AppLocalizations.of(context)!.financial_list,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 5.0,
            ),
            Container(
              width: 140,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
              color: Colors.red,
              child: DropdownButtonHideUnderline(
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                      hint: Text(AppLocalizations.of(context)!.select_year,
                          style: TextStyle(color: Colors.white)),
                      selectedValue: yearSelected,
                      dropdownItems: yearsData,
                      onChanged: (String? newValue) async {
                        yearSelected = newValue!.toString();
                        setState(() {
                          yearSelected = newValue!;
                        });
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        user = User.fromJson(
                            json.decode(prefs.getString("user")!));
                        print(user.businessId);
                        Map<String, dynamic> data = {
                          "dateYearRequest": yearSelected!,
                          "business_id": user.businessId
                        };
                        FinancialPageProvider providerGetMinutesByDateYear =
                            Provider.of<FinancialPageProvider>(context,
                                listen: false);
                        Future.delayed(Duration.zero, () {
                          providerGetMinutesByDateYear
                              .getListOfFinancials(data);
                        });
                      }, color:  Colors.black,)),
            )
          ],
        ),
      );

  Future openFinancialCreateDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 100),
              title: const Text("Add New Financial",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              content: Form(
                key: insertFinancialFormGlobalKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.black12,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Column(
                        children: [
                          StandTextFormField(
                            color: Colors.redAccent,
                            icon: Icons.people,
                            labelText: "Financial Name",
                            valid: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Enter a valid Financial Name';
                              }
                            },
                            controllerField: financialName,
                          ),
                          const SizedBox(height: 15),
                          DateFormatTextFormField(
                            dateinput: financialDate,
                            labelText: "Financia Date",
                            onTap: () {
                              onTapGetDate(financialDate);
                            },
                            icon: Icons.calendar_today,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            constraints:
                            const BoxConstraints(minHeight: 30.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10.0),
                                color: Colors.red,
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 2.0,
                                      spreadRadius: 0.4)
                                ]),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isExpanded: true,
                                isDense: true,
                                menuMaxHeight: 300,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6,
                                hint: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .select_meeting_name,
                                    color: Colors.white),
                                dropdownColor: Colors.white60,
                                focusColor: Colors.redAccent[300],
                                // Initial Value
                                value: meeting_id,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: Colors.white),
                                // Array list of items
                                items: [
                                  DropdownMenuItem(
                                    value: "",
                                    child: CustomText(
                                        text: AppLocalizations.of(
                                            context)!
                                            .select_meeting_name,
                                        color: Colors.white),
                                  ),
                                  ..._listOfMeetingsData!.meetings!
                                      .map((Meeting meeting) {
                                    return DropdownMenuItem(
                                      value:
                                      meeting.meetingId.toString(),
                                      child: CustomText(
                                          text: meeting.meetingTitle!,
                                          color: Colors.black),
                                    );
                                  }).toList(),
                                ],
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (String? newValue) {
                                  setState(() {
                                    meeting_id = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          imageProfile(),
                          const SizedBox(height: 10),
                          InkWell(
                              onTap: () {
                                pickedFile();
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: Text(
                                  'Upload Financial File',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                        ],
                      )),
                ),
              ),
              actions: [
                Consumer<FinancialPageProvider>(
                    builder: (context, provider, child) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        provider.loading == true
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                          label: const Text(
                            'Add Financial',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            user = User.fromJson(json.decode(prefs.getString("user")!));
                            setState(() { _business_id = user.businessId.toString();});
                            if (insertFinancialFormGlobalKey.currentState!.validate()) {
                              insertFinancialFormGlobalKey.currentState!.save();
                              if (pickedFiles != null) {
                                final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
                                setState(() { _fileBase64 = fileBase64;});
                              }

                              Map<String, dynamic> data = {
                                "financial_date": financialDate.text,
                                "financial_name": financialName.text,
                                "financial_file": _fileNameNew!,
                                "fileSelf": _fileBase64!,
                                "business_id": _business_id,
                                "add_by": user.userId.toString(),
                                "meeting_id": meeting_id
                              };
                              await providerFinancial.insertFinancial(data);
                              if (providerFinancial.isBack == true) {
                                financialName.text = '';
                                financialDate.text = '';
                                financialFile.text = '';
                                pickedFiles = null;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .remove_minute_done),
                                    backgroundColor: Colors.greenAccent,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: CustomText(text: AppLocalizations.of(context)!.remove_minute_failed),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]);
                })
              ],
            );
          });
        });
  }

  Future dialogDeleteFinancial(FinancialModel financial) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.are_you_sure_to_delete} ${financial.financialName!} ?",
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_delete,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                removeFinancial(financial);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void removeFinancial(FinancialModel financial)async {
     await providerFinancial.removeFinancial(financial);
    if (providerFinancial.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: AppLocalizations.of(context)!.remove_minute_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
        Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future dialogToMakeSignFinancial(FinancialModel financial) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.are_you_sure} ${financial.financialName!} ${AppLocalizations.of(context)!.to_sign}",
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_sure,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                makeSignOnFinancial(financial);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void makeSignOnFinancial(FinancialModel financial) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> data = {"financial_id": financial.financialId!,"member_id": 7};
    final Future<Map<String, dynamic>> response = providerFinancial.makeSignedFinancial(data);
    response.then((response) {
      if (response['status']) {
        providerFinancial.setIsBack(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_successfully),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      } else {
        providerFinancial.setIsBack(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_failed),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future dialogDownloadFinancial(FinancialModel financial) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.yes_sure_download} ${financial.financialName!} ?",
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_download,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.download, color: Colors.white),
                              onPressed: () async {
                                print('no function yet in download');
                                downloadFinancial(financial);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  Future<void> downloadFinancial(FinancialModel financial) async {
    final pdfFile = await PdfFinancialApi.generate(financial, context);
    if (await PDFApi.requestPermission()) {
      await PDFApi.downloadFileToStorage(pdfFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    } else {
      print('permission error--------------');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }


  void onTapGetDate(TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(pickedDate);
      print(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        passDate.text = formattedDate; //set output date to TextField value.
      });
    } else {
      print("Date is not selected");
    }
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.brown.shade800,
              radius: 50.0,
              child: pickedFiles?.name == null
                  ? Icon(
                      Icons.upload_file,
                      size: 24.0,
                    )
                  : Text(
                      pickedFiles!.name,
                      style: TextStyle(color: Colors.white),
                    )),
        ],
      ),
    );
  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  // void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
  //   MaterialPageRoute(builder: (context) => PDFViewerPageAsyncfusion(file: file,fileName: fileName,)),
  // );


}
