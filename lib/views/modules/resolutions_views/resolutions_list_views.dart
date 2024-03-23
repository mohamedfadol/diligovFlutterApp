import 'dart:convert';

import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:diligov/models/user.dart';
import '../../../NetworkHandler.dart';
import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../models/resolutions_model.dart';
import '../../../providers/resolutions_page_provider.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_resolution_board.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/date_format_text_form_field.dart';
import '../../../widgets/stand_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ResolutionsListViews extends StatefulWidget {
  const ResolutionsListViews({Key? key}) : super(key: key);
  static const routeName = '/ResolutionsListViews';

  @override
  State<ResolutionsListViews> createState() => _ResolutionsListViewsState();
}

class _ResolutionsListViewsState extends State<ResolutionsListViews> {
  final insertResolutionFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late String _business_id;
  FilePickerResult? result;
  TextEditingController ResolutionStartDate = TextEditingController();
  TextEditingController endFiscalYear = TextEditingController();
  TextEditingController _ResolutionName = TextEditingController();
  TextEditingController _ResolutionDecision = TextEditingController();
  // Initial Selected Value
  String yearSelected = '2023';
  late List _listOfBoardsData = [];
  String? board_id = "";
  Future getListBoards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler
        .get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards response statusCode == 200");
      var responseData = json.decode(response.body);
      var boardsData = responseData['data'];
      setState(() {
        _listOfBoardsData = boardsData['boards'];
        // print(_listOfBoardsData);
      });
    } else {
      log.d("get-list-boards response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  late List _listOfMeetingsData = [];
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
        _listOfMeetingsData = meetingsData['meetings'];
        // print(_listOfMeetingsData);
      });
    } else {
      log.d("get-list-meetings response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      PdfPragraphResolutionBoardApi.getLocale(context);
      PdfPragraphResolutionBoardApi.getTextDirection(context);
      PdfPragraphResolutionBoardApi.getTextAlign(context);
      PdfPragraphResolutionBoardApi.getLocale(context);
      PdfPragraphResolutionBoardApi.getLang(context);
      getListBoards();
      getListMeetings();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ResolutionStartDate.dispose();
    _ResolutionName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(),
              Center(
                child: Consumer<ResolutionsPageProvider>(
                    builder: (context, provider, child) {
                  if (provider.resolutionsData?.resolutions == null) {
                    provider.getListOfBoardsResolutions(context);
                    return Center(
                      child: SpinKitThreeBounce(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: index.isEven ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return provider.resolutionsData!.resolutions!.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0)),
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: CustomText(
                              text:
                                  AppLocalizations.of(context)!.no_data_to_show,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ))
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
                                          .resolution_name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show Resolution name"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.date,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show Resolution Date"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.file,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "File"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!
                                          .meeting_name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "Meeting"),
                                DataColumn(
                                    label: CustomText(
                                      text:
                                          AppLocalizations.of(context)!.signed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "Signed"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.owner,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "Owner"),
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
                              rows: provider!.resolutionsData!.resolutions!
                                  .map((resolution) => DataRow(cells: [
                                        BuildDynamicDataCell(
                                          child: CustomText(text:resolution!.resoultionName!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                      BuildDynamicDataCell(
                                        child: CustomText(text:resolution!.resoultionDate!,
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                  BuildDynamicDataCell(
                                    child:  TextButton(
                                                onPressed: () async {
                                                  final pdfFile =
                                                  await PdfPragraphResolutionBoardApi.generate(resolution, context);
                                                  PDFApi.openFile(pdfFile);
                                                },
                                                child: CustomText(text: resolution?.meeting?.meetingFile ?? 'Show File',fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false, maxLines: 1,overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                      ),



                                      BuildDynamicDataCell(
                                        child: CustomText(text: resolution?.meeting?.meetingTitle ?? 'Circular',
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      BuildDynamicDataCell(
                                        child: CustomText(text:resolution!.resoultionStatus!,
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      BuildDynamicDataCell(
                                        child: CustomText(text: resolution?.user?.firstName ?? "Loading ...",
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
                                                                  Colors.white,
                                                              buttonBackgroundColor:
                                                                  Colors.red,
                                                              horizontalPadding:
                                                                  10.0,
                                                              callFunction:
                                                                  () async {
                                                                print(
                                                                    'View done');
                                                                final pdfFile =
                                                                    await PdfPragraphResolutionBoardApi.generate(
                                                                        resolution,
                                                                        context);
                                                                PDFApi.openFile(
                                                                    pdfFile);
                                                              }),
                                                    ),
                                                    PopupMenuItem<int>(
                                                        value: 1,
                                                        child:
                                                            CustomElevatedButton(
                                                                verticalPadding:
                                                                    0.0,
                                                                text: AppLocalizations
                                                                        .of(
                                                                            context)!
                                                                    .export,
                                                                icon: Icons
                                                                    .import_export_outlined,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                buttonBackgroundColor:
                                                                    Colors.red,
                                                                horizontalPadding:
                                                                    10.0,
                                                                callFunction:
                                                                    () async {
                                                                  print('Export');
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
                                                            callFunction: () =>
                                                                dialogToMakeSignResolution(
                                                                    resolution))),
                                                    PopupMenuItem<int>(
                                                        value: 4,
                                                        child: CustomElevatedButton(
                                                            verticalPadding:
                                                                0.0,
                                                            text:
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .delete,
                                                            icon: Icons
                                                                .restore_from_trash_outlined,
                                                            textColor:
                                                                Colors.white,
                                                            buttonBackgroundColor:
                                                                Colors.red,
                                                            horizontalPadding:
                                                                10.0,
                                                            callFunction: () =>
                                                                dialogDeleteResolution(
                                                                    resolution))),
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

  Future openResolutionCreateDialog() => showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 100),
            title: CustomText(
                text: AppLocalizations.of(context)!.add_new_resolution,
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            content: Form(
              key: insertResolutionFormGlobalKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    color: Colors.black12,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Column(
                      children: [
                        StandTextFormField(
                          color: Colors.redAccent,
                          icon: Icons.border_color_outlined,
                          labelText: "Resolution Name",
                          valid: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return 'Enter a valid Resolution Name';
                            }
                          },
                          controllerField: _ResolutionName,
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 100,
                            child: TextFormField(
                              maxLines: null,
                              expands: true,
                              controller: _ResolutionDecision,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.teal,
                                )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                )),
                                prefixIcon: Icon(
                                  Icons.book_rounded,
                                  color: Colors.redAccent,
                                ),
                                labelText: "Resolution Decision",
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
                                errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              validator: (val) {
                                if (val!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Enter a valid Resolution Decision';
                                }
                              },
                            )),
                        const SizedBox(height: 15),
                        DateFormatTextFormField(
                          dateinput: ResolutionStartDate,
                          labelText: "Start Resolution Date",
                          onTap: () {
                            onTapGetDate(ResolutionStartDate);
                          },
                          icon: Icons.calendar_today,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 15),
                        buildMeetingAndResolutionDropDownList(),
                        const SizedBox(height: 15),
                        buildBoardDropdown(),
                      ],
                    )),
              ),
            ),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton.icon(
                  // style: ButtonStyle(backgroundColor: Colors.white),
                  label: CustomText(
                    text: AppLocalizations.of(context)!.add_resolution,
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    user = User.fromJson(json.decode(prefs.getString("user")!));
                    setState(() {
                      _business_id = user.businessId.toString();
                    });
                    if (insertResolutionFormGlobalKey.currentState!
                        .validate()) {
                      insertResolutionFormGlobalKey.currentState!.save();
                      Map<String, dynamic> data = {
                        "date": ResolutionStartDate.text,
                        "resolution_decision": _ResolutionDecision.text,
                        "meeting_id": meeting_id,
                        "board_id": board_id,
                        "add_by": user.userId,
                        "resoultion_name": _ResolutionName.text,
                        "business_id": _business_id
                      };
                      ResolutionsPageProvider providerResolution =
                          Provider.of<ResolutionsPageProvider>(context,
                              listen: false);
                      Future.delayed(Duration.zero, () {
                        providerResolution.insertResolution(data);
                      });
                      if (providerResolution.isBack == true) {
                        Navigator.pop(context);

                        Flushbar(
                          title: AppLocalizations.of(context)!
                              .create_resolution_successfully,
                          message: AppLocalizations.of(context)!
                              .create_resolution_successfully,
                          duration: Duration(seconds: 6),
                          backgroundColor: Colors.greenAccent,
                          titleColor: Colors.white,
                          messageColor: Colors.white,
                        ).show(context);
                      } else {
                        Flushbar(
                          title: AppLocalizations.of(context)!
                              .create_resolution_failed,
                          message: AppLocalizations.of(context)!
                              .create_resolution_failed,
                          duration: const Duration(seconds: 6),
                          backgroundColor: Colors.redAccent,
                          titleColor: Colors.white,
                          messageColor: Colors.white,
                        ).show(context);
                      }
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CustomText(
                      text: AppLocalizations.of(context)!.no_cancel,
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ],
          );
        });
      });

  Widget buildMeetingAndResolutionDropDownList() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 30.0),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.red,
                  boxShadow: const [
                    BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                  ]),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  isDense: true,
                  menuMaxHeight: 300,
                  style: Theme.of(context).textTheme.headline6,
                  hint: CustomText(
                      text: AppLocalizations.of(context)!.meeting_belongs_to,
                      color: Colors.white),
                  dropdownColor: Colors.white60,
                  focusColor: Colors.redAccent[300],
                  // Initial Value
                  value: meeting_id,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.white),
                  // Array list of items
                  items: [
                    DropdownMenuItem(
                      value: "",
                      child: CustomText(
                          text:
                              AppLocalizations.of(context)!.meeting_belongs_to,
                          color: Colors.white),
                    ),
                    ..._listOfMeetingsData!.map((item) {
                      return DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['meeting_title'],
                            style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                  ],
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    meeting_id = newValue!;
                    setState(() {
                      meeting_id = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      );

  Widget buildBoardDropdown() => Container(
        constraints: const BoxConstraints(minHeight: 30.0),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.red,
            boxShadow: const [BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)]),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            isDense: true,
            menuMaxHeight: 300,
            style: Theme.of(context).textTheme.headline6,
            hint: CustomText(
                text: AppLocalizations.of(context)!.select_board,
                color: Colors.white),
            dropdownColor: Colors.white60,
            focusColor: Colors.redAccent[300],
            // Initial Value
            value: board_id,
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 20, color: Colors.white),
            // Array list of items
            items: [
              DropdownMenuItem(
                value: "",
                child: CustomText(
                    text: AppLocalizations.of(context)!.select_board,
                    color: Colors.white),
              ),
              ..._listOfBoardsData!.map((item) {
                return DropdownMenuItem(
                  value: item['id'].toString(),
                  child: Text(item['board_name'],
                      style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
            ],
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) {
              board_id = newValue?.toString();
              setState(() {
                board_id = newValue!;
              });
            },
          ),
        ),
      );

  Widget buildFullTopFilter() => Padding(
        padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colors.red,
              child: CustomText(
                  text: AppLocalizations.of(context)!.board_resolutions_list,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Container(
              width: 140,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colors.red,
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  isDense: true,
                  menuMaxHeight: 300,
                  style: Theme.of(context).textTheme.headline6,
                  hint: CustomText(
                    text: AppLocalizations.of(context)!.select_year,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.white60,
                  focusColor: Colors.redAccent[300],
                  // Initial Value
                  value: yearSelected,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.white),
                  // Array list of items
                  items: [
                    DropdownMenuItem(
                      value: "",
                      child: CustomText(
                          text: AppLocalizations.of(context)!.select_year,
                          color: Colors.black),
                    ),
                    ...yearsData!.map((item) {
                      return DropdownMenuItem(
                        value: item.toString(),
                        child: Text(item,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ],
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) async {
                    yearSelected = newValue!.toString();
                    setState(() {
                      yearSelected = newValue!;
                    });
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    user = User.fromJson(json.decode(prefs.getString("user")!));
                    print(user.businessId);
                    Map<String, dynamic> data = {
                      "dateYearRequest": yearSelected!,
                      "business_id": user.businessId
                    };
                    ResolutionsPageProvider providerGetResolutionsByDateYear =
                        Provider.of<ResolutionsPageProvider>(context,
                            listen: false);
                    Future.delayed(Duration.zero, () {
                      providerGetResolutionsByDateYear
                          .getListOfBoardsResolutions(data);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              color: Colors.red,
              child: IconButton(
                  onPressed: () {
                    openResolutionCreateDialog();
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
                  )),
            ),
          ],
        ),
      );

  void onTapGetDate(TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
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

  Future dialogDeleteResolution(Resolution resolution) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${resolution.resoultionName!} ${AppLocalizations.of(context)!.to_delete}",
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
                            removeResolution(resolution);
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

  void removeResolution(Resolution resolution) {
    final provider =
        Provider.of<ResolutionsPageProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      provider.removeResolution(resolution);
      provider.setIsBack(true);
    });
    if (provider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_done),
          backgroundColor: Colors.greenAccent,
          duration: const Duration(seconds: 6),
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_failed),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 6),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future dialogToMakeSignResolution(Resolution resolution) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${resolution.resoultionName!} ${AppLocalizations.of(context)!.to_sign}",
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
                            makeSignOnResolution(resolution);
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

  void makeSignOnResolution(Resolution resolution) async {
    final providerMakeResolutionsSign =
        Provider.of<ResolutionsPageProvider>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> data = {
      "resolution_id": resolution.resoultionId!,
      "member_id": user.userId
    };
    final Future<Map<String, dynamic>> response =
        providerMakeResolutionsSign.makeSignedResolution(data);
    response.then((response) {
      if (response['status']) {
        providerMakeResolutionsSign.setIsBack(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(
                    text: AppLocalizations.of(context)!.signed_successfully),
                const SizedBox(
                  height: 10.0,
                ),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      } else {
        providerMakeResolutionsSign.setIsBack(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_failed),
                const SizedBox(
                  height: 10.0,
                ),
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
}
