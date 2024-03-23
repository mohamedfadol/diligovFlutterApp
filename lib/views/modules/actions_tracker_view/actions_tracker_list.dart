import 'dart:convert';

import 'package:diligov/providers/actions_tracker_page_provider.dart';
import 'package:diligov/providers/member_page_provider.dart';
import 'package:diligov/utility/pdf_action_trackes_api.dart';
import 'package:diligov/views/modules/meetings/show_meeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../colors.dart';
import '../../../models/action_tracker_model.dart';
import '../../../models/data/years_data.dart';
import '../../../models/member.dart';
import '../../../models/user.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/utils.dart';

import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/date_format_text_form_field.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/stand_text_form_field.dart';

class ActionsTrackerList extends StatefulWidget {
  ActionsTrackerList({super.key});
  static const routeName = '/ActionsTrackerList';

  @override
  State<ActionsTrackerList> createState() => _ActionsTrackerListState();
}

class _ActionsTrackerListState extends State<ActionsTrackerList> {
  var log = Logger();
  User user = User();
  // Initial Selected Value
  String yearSelected = '2024';
  String statusSelected = 'Status';
  final insertActionsTrackerGlobalKey = GlobalKey<FormState>();
  TextEditingController dateDue = TextEditingController();
  TextEditingController actionNote = TextEditingController();

  String? member_id = "";

  late ActionsTrackerPageProvider providerUpdateAction;
  late MemberPageProvider memberPageProvider = Provider.of<MemberPageProvider>(context, listen: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PdfActionTrackesAPI.getLocale(context);
    PdfActionTrackesAPI.getTextDirection(context);
    PdfActionTrackesAPI.getTextAlign(context);
    PdfActionTrackesAPI.getLocale(context);
    // PdfActionTrackesAPI.getLang(context);
    providerUpdateAction = Provider.of<ActionsTrackerPageProvider>(context, listen: false);
    memberPageProvider.getListOfMember(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: Header(context),
      floatingActionButton: providerUpdateAction?.actionsData?.actions != null ? FloatingActionButton.extended(
        onPressed: () async {
          print('View actions done');
          final List<ActionTracker>? dataList = providerUpdateAction?.actionsData?.actions;
          final pdfFile = await PdfActionTrackesAPI.generate(dataList, context);
          if (await PDFApi.requestPermission()) {
            await PDFApi.openFile(pdfFile);
          }else {
            print('permission error--------------');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(text:'you don\'t have permission open file'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }

        },
        backgroundColor: Colors.red,
        label: CustomText(
            text: AppLocalizations.of(context)!.add_to_next_meeting_agenda,
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        icon: CustomIcon(
          icon: Icons.picture_as_pdf,
          color: Colors.white,
        ),
      ) : FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () {},
        label: CustomText(
          text: AppLocalizations.of(context)!.add_to_next_meeting_agenda,
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold),
        icon: CustomIcon(
          icon: Icons.picture_as_pdf,
          color: Colors.white,
        ),

      ),
      body: Container(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(),
              Center(
                child: Consumer<ActionsTrackerPageProvider>(
                    builder: (context, provider, child) {
                  if (provider.actionsData?.actions == null) {
                    provider.getListOfActionTrackers(context);
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
                  return provider.actionsData!.actions!.isEmpty
                      ? Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: CustomText(
                              text:
                                  AppLocalizations.of(context)!.no_data_to_show,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          )
                      )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Theme(
                              data: theme.copyWith(
                                  iconTheme: const IconThemeData(color: Colors.white,),
                              ),
                              child: DataTable(
                                sortColumnIndex: provider.currentSortColumn,
                                sortAscending: provider.isAscending,
                                showBottomBorder: true,
                                dividerThickness: 5.0,
                                headingRowColor: MaterialStateColor.resolveWith((states) => Colour().darkHeadingColumnDataTables),
                                // dataRowColor: MaterialStateColor.resolveWith((states) => Colour().lightBackgroundColor),
                                columns: <DataColumn>[
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!.action_name,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show tasks name",
                                      onSort: (columnIndex, _) {
                                        provider.sortByTaskName(columnIndex);
                                      },
                                  ),

                                  DataColumn(
                                      label: CustomText(text: AppLocalizations.of(context)!.action_date_assigned,fontWeight: FontWeight.bold,fontSize: 18.0,color: Colour().lightBackgroundColor,),
                                      tooltip: "show action Date assigned",
                                      onSort: (columnIndex, _) {
                                       provider.sortByActionDateAssigned(columnIndex);
                                      },
                                  ),

                                  DataColumn(
                                      label: CustomText(text: AppLocalizations.of(context)!.action_date_due,fontWeight: FontWeight.bold,fontSize: 18.0,color: Colour().lightBackgroundColor,),
                                      tooltip: "show action Date due",
                                      onSort: (columnIndex, _) {
                                        provider.sortByActionDateDue(columnIndex);
                                      },
                                  ),

                                  DataColumn(
                                      label: positionNameSearch(),
                                      tooltip: "Owner",
                                    onSort: (columnIndex, _) {
                                    },
                                  ),

                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .meeting_name,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "Meeting",
                                      onSort: (columnIndex, _) {
                                        provider.sortByActionMeetingName(columnIndex);
                                      },
                                  ),

                                  DataColumn(
                                      label: actionStatusSearch(),
                                      tooltip: "action status",
                                      onSort: (columnIndex, _) {
                                        provider.sortByStatus(columnIndex);
                                    },
                                  ),

                                  DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!
                                          .action_note,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "action note",
                                  ),

                                  DataColumn(
                                      label: CustomText(
                                        text:
                                            AppLocalizations.of(context)!.actions,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip:
                                          "show buttons for functionality action tracker"),
                              ],
                                rows: provider!.actionsData!.actions!
                                    .map((action) => DataRow(cells: [
                                        BuildDynamicDataCell(
                                          child: SizedBox(
                                            width : 150.0,
                                            child: CustomText(text: action.actionsTasks!,fontWeight: FontWeight.bold,
                                                      fontSize: 14.0,softWrap: false,maxLines: 1,overflow: TextOverflow.clip,
                                                    ),
                                          )
                                        ),

                                        BuildDynamicDataCell(
                                          child: CustomText(text: action!.actionsDateAssigned!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        BuildDynamicDataCell(
                                          child: CustomText(text: action?.actionsDateDue ??"No Date Yet",
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        BuildDynamicDataCell(
                                          child: CustomText(text: action?.member?.position?.positionName ?? "Not Assigned Yet",
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        BuildDynamicDataCell(
                                          child: action?.meeting! != null ?
                                          TextButton(
                                              onPressed: () async { Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowMeeting(meeting: action.meeting!,)));},
                                              child: CustomText(text: action?.meeting?.meetingTitle ?? 'Circular',fontWeight: FontWeight.bold,fontSize: 14.0,)
                                          ) : CustomText(text: action?.meeting?.meetingTitle ?? 'Circular',fontWeight: FontWeight.bold,fontSize: 14.0,),
                                        ),

                                        BuildDynamicDataCell(
                                          child: CustomText(text: action!.actionStatus!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        BuildDynamicDataCell(
                                        child: CustomText(text: action?.actionNote?? "",
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                        DataCell(IconButton(
                                          icon: CustomIcon(icon: Icons.settings,size: 30.0,color: Colors.black,),
                                          onPressed: () => openEditActionTrackerDialog(action)

                                        ) ),
                                      ])).toList(),
                              ),
                            ),
                          ),
                        );
                }),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget buildFullTopFilter() => Padding(
        padding: const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colors.red,
              child: CustomText(text: AppLocalizations.of(context)!.action_tracker,color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0,),
            Container(
              width: 140,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colors.red,
              child: DropdownButtonHideUnderline(
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(text: AppLocalizations.of(context)!.select_year,color: Colors.white) ,
                    selectedValue: yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      yearSelected = newValue!.toString();
                      setState(() {yearSelected = newValue!;});
                      Map<String, dynamic> data = {"dateYearRequest": yearSelected!};
                      ActionsTrackerPageProvider providerGetActionsTrackersByDateYear = Provider.of<ActionsTrackerPageProvider>(context,listen: false);
                      Future.delayed(Duration.zero, () {providerGetActionsTrackersByDateYear.getListOfActionTrackers(data);});
                  },
                    color: Colors.grey,
              ),
              ),
            ),
          ],
        ),
      );

  Future openEditActionTrackerDialog(ActionTracker action) {
    memberPageProvider = Provider.of<MemberPageProvider>(context, listen: false);
    return showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 100),
              title: CustomText(
                  text: AppLocalizations.of(context)!.edit_action,
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: Form(
                key: insertActionsTrackerGlobalKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      padding: EdgeInsets.only(bottom: 7.0, right: 7.0,left: 7.0,top: 0.0),
                      color: Colors.black12,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 15),
                          CustomText(text: AppLocalizations.of(context)!.select_member_name,color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold),
                          Container(
                            constraints: const BoxConstraints(minHeight: 30.0),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                color: Colors.red,
                                boxShadow: const [BoxShadow(blurRadius: 2.0,spreadRadius: 0.4)]),
                            child: DropdownButtonHideUnderline(
                              child: Consumer<MemberPageProvider>
                                (builder: (BuildContext context, provider, child) {
                                if (provider.dataOfMembers?.members == null) {
                                  provider.getListOfMember(context);
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
                                return provider.dataOfMembers!.members!.isEmpty
                                    ? Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CustomText(
                                        text:
                                        AppLocalizations.of(context)!.no_data_to_show,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    )
                                )
                                    : DropdownButton<String>(
                                    isExpanded: true,
                                    isDense: true,
                                    menuMaxHeight: 300,
                                    style: Theme.of(context).textTheme.headline6,
                                    hint: CustomText(text: AppLocalizations.of(context)!.select_member_name,color: Colors.white),
                                    dropdownColor: Colors.white60,
                                    focusColor: Colors.redAccent[300],
                                    // Initial Value
                                    value: provider.dataOfMembers?.members?.first?.memberId.toString(),
                                    icon: const Icon(Icons.keyboard_arrow_down,size: 20,color: Colors.white),
                                    // Array list of items
                                    items: provider.dataOfMembers!.members!
                                          .map((Member member) {
                                            return DropdownMenuItem(
                                              value: member.memberId.toString(),
                                              child: CustomText(text: '${member?.memberFirstName ?? ''} ${member?.memberMiddelName ?? ''} ${member?.memberLastName ?? ''}',color: Colors.black),
                                            );
                                          }).toList(),

                                    // After selecting the desired option,it will
                                    // change button value to selected value
                                    onChanged: (String? newValue) {
                                      // member_id = newValue!;
                                      setState(() {
                                        member_id = newValue!;
                                        print(member_id);
                                      });
                                    },

                                  );
                              },

                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          CustomText(text: AppLocalizations.of(context)!.select_status,color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold),
                           Container(
                            constraints:
                                const BoxConstraints(minHeight: 30.0),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                color: Colors.red,
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 2.0,
                                      spreadRadius: 0.4)
                                ]),
                            child: DropdownButtonHideUnderline(
                                child: DropdownStringList(
                                  boxDecoration: Colors.white,
                                  hint: CustomText(text: AppLocalizations.of(context)!.select_status,color: Colors.white,),
                                  selectedValue: statusSelected,
                                  dropdownItems: statusActionsTracker,
                                  onChanged: (String? newValue) async {
                                      setState(() { statusSelected = newValue!.toString(); });
                                  }, color: Colors.black,
                                )
                            ),
                          ),
                          const SizedBox(height: 15),
                          CustomText(text: "Set date due",color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold),
                          DateFormatTextFormField(
                            dateinput: dateDue,
                            labelText: "Set date due",
                            onTap: () {
                              onTapGetDate(dateDue);
                            },
                            icon: Icons.calendar_today,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 15),
                          CustomText(text: "action Note",color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold),

                          StandTextFormField(
                            color: Colors.redAccent,
                            icon: Icons.border_color_outlined,
                            labelText: "Action Note",
                            valid: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              }
                            },
                            controllerField: actionNote,
                          ),
                        ],
                      )),
                ),
              ),
              actions: [
                Consumer<ActionsTrackerPageProvider>(
                    builder: (context, provider, child) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        provider.load == true
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                label: CustomText(text: AppLocalizations.of(context)!.edit_action,color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold,),
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () async {
                                  if (insertActionsTrackerGlobalKey.currentState!.validate()) {
                                    insertActionsTrackerGlobalKey.currentState!.save();
                                    final SharedPreferences prefs =await SharedPreferences.getInstance();
                                    user = User.fromJson(json.decode(prefs.getString("user")!));
                                    Map<String, dynamic> data = {
                                      "action_id": action.actionsId.toString(),
                                      "date_due": dateDue.text,
                                      "note": actionNote.text,
                                      "member_id": member_id.toString(),
                                      "action_status": statusSelected,
                                      "business_id": user.businessId.toString()
                                    };
                                    print(data);
                                    await providerUpdateAction.updateActionTracker(data, action);
                                    if (providerUpdateAction.isBack == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: CustomText(text:AppLocalizations.of(context)!.remove_minute_done),
                                          backgroundColor: Colors.greenAccent,
                                          duration: const Duration(seconds: 6),
                                        ),
                                      );
                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .remove_minute_failed),
                                          backgroundColor: Colors.redAccent,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                              ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: CustomText(
                              text: AppLocalizations.of(context)!.close,
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ]);
                })
              ],
            );
          });
        });
  }

  void onTapGetDate(TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(pickedDate);
      //you can implement different kind of Date Format here according to your requirement
      setState(() {
        passDate.text = formattedDate; //set output date to TextField value.
      });
    } else {
      print("Date is not selected");
    }
  }

  Widget  positionNameSearch() {
    return DropdownButtonHideUnderline(
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        color: Colour().darkHeadingColumnDataTables,
        child: Consumer<MemberPageProvider>(
          builder: (BuildContext context, provider, child) {
            if (provider.dataOfMembers?.members == null) {
              provider.getListOfMember(context);
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
            return provider.dataOfMembers!.members!.isEmpty
                ? Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: CustomText(
                  text: AppLocalizations.of(context)!.no_data_to_show,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            )
                :
            DropdownButton<Member>(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.headline6,
              hint: CustomText(text:provider.selectedMember?.position?.positionName??'Owner', color: Colors.white),
              value: provider.selectedMember,
              items: provider.dataOfMembers!.members!.map<DropdownMenuItem<Member>>((Member member) {
                return DropdownMenuItem(
                  value: member,
                  child: CustomText(text: ' ${member?.position?.positionName ?? ''}', color: Colors.black),
                );
              }).toList(),
              onChanged: (Member? member) async{
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                user = User.fromJson(json.decode(prefs.getString("user")!));
                // provider.setSelectedMember(member);
                Map<String, dynamic> data = {
                  "position_name": member?.position?.positionName??'',
                  "business_id": user.businessId.toString()
                };
                providerUpdateAction.getListOfActionTrackersWhereLike(data);
                // providerUpdateAction.sortByOwner(member?.position?.positionName??'');
              },
            );
          },
        ),
      ),
    );
  }

  Widget  actionStatusSearch() {
    return DropdownButtonHideUnderline(
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          color: Colour().darkHeadingColumnDataTables,
          child: DropdownStringList(
            boxDecoration: Colour().darkHeadingColumnDataTables,
            hint: CustomText(text: AppLocalizations.of(context)!.select_status,color: Colors.white,),
            selectedValue: statusSelected,
            dropdownItems: statusActionsTracker,
            color: Colors.black,
            onChanged: (String? newValue) async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              user = User.fromJson(json.decode(prefs.getString("user")!));
              Map<String, dynamic> data = {
                "action_status": newValue!.toString()??'',
                "business_id": user.businessId.toString()
              };
              providerUpdateAction.getListOfActionTrackersWhereLike(data);
            }

          ),
        )
    );
  }

}
