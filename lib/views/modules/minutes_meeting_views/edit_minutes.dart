import 'dart:convert';

import 'package:diligov/models/agenda_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/agenda_details.dart';
import '../../../models/minutes_model.dart';
import '../../../models/user.dart';
import '../../../providers/minutes_provider_page.dart';
import '../../../widgets/custome_text.dart';
import 'minutes_meeting_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class EditMinutes extends StatefulWidget {
  final Minute minute;
  const EditMinutes({Key? key, required this.minute}) : super(key: key);
  @override
  State<EditMinutes> createState() => _EditMinutesState();
}

class _EditMinutesState extends State<EditMinutes> {
  final updateMinutesDetailsFormGlobalKey = GlobalKey<FormState>();
  User user = User();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  List<AgendaDetails> agendaList =[];
  List<Map<String, dynamic>> details =[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: buildMinuteTitle(widget.minute),
        centerTitle: true,
        backgroundColor: Colors.red,
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
        child: Form(
          key: updateMinutesDetailsFormGlobalKey,
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: List.generate(widget.minute.meeting!.agendas!.length, (i) {
              final summaryController = TextEditingController();
              final tasksController = TextEditingController();
              final reservationController = TextEditingController();
              final Agenda agenda = widget.minute.meeting!.agendas![i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAgendaTitle(agenda),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Text('$i'),
                        const SizedBox(width: 6,),
                        Flexible(
                          child: SizedBox(
                            height: 100,
                            child: TextFormField(
                              controller: summaryController,
                              maxLines: null,
                              expands: true,
                              validator: (val) => val != null && val.isEmpty ? 'please enter Summary of Discussion' : null,
                              style: const TextStyle(fontSize: 17,color: Colors.black),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal,)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    )
                                ),
                                hintText: "Summary of Discussion",
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              ),
                              onFieldSubmitted: (_) => saveForm(),
                            ),
                          ),
                        ) ,
                        const SizedBox(width: 6,),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: TextFormField(
                              controller: tasksController,
                              maxLines: null,
                              expands: true,
                              validator: (val) => val != null && val.isEmpty ? 'please enter Tasks' : null,
                              style: const TextStyle(fontSize: 17),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal,)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    )
                                ),
                                hintText: "Summary of Tasks",
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              ),
                              onFieldSubmitted: (_) => saveForm(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6,),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: TextFormField(
                              controller: reservationController,
                              maxLines: null,
                              expands: true,
                              validator: (val) => val != null && val.isEmpty ? 'please enter Reservations' : null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal,)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    )
                                ),
                                hintText: "Summary of Reservations",
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              ),
                              onFieldSubmitted: (_) => saveForm(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6,),
                        Column(
                          children: [
                            FloatingActionButton.extended(
                                heroTag: "btn1${i+1}",
                                label: CustomText(text: AppLocalizations.of(context)!.update_details,color: Colors.white), // <-- Text
                                backgroundColor: Colors.red,
                                icon: const Icon(Icons.add,size: 25.0,color: Colors.white),
                                onPressed: () {
                                  print(i);
                                  final isValid = updateMinutesDetailsFormGlobalKey.currentState!.validate();
                                  agendaList!.add(
                                      AgendaDetails(
                                          index: i,
                                          agendaId: agenda.agendaId,
                                          missions: summaryController.text,
                                          tasks: tasksController.text,
                                          reservations: reservationController.text
                                      )
                                  );
                                  var removedDuplicatedData = agendaList.toSet().toList();
                                  List<Map<String, dynamic>> detailsFilter = [];
                                  for (int i = 0; i < removedDuplicatedData.length; i++) {
                                    detailsFilter.add({
                                      "agenda_id": removedDuplicatedData[i].agendaId,
                                      "missions": removedDuplicatedData[i].missions,
                                      "tasks": removedDuplicatedData[i].tasks,
                                      "reservations": removedDuplicatedData[i].reservations,
                                    });
                                  }
                                  details = detailsFilter;
                                }
                            ),
                            const SizedBox(height: 6,),
                            TextButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                onPressed: (){
                                  agendaList.removeWhere((element) => element.index == i,);
                                  details.removeWhere((element) => element['agenda_id'] == agenda.agendaId);
                                }, child: CustomText(text:AppLocalizations.of(context)!.remove_details,color: Colors.white,)
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            }
            ),
          ),
        ),
      ),
    );
  }

  agendaDetailsForm(int i,Agenda agenda) {
    final summaryController = TextEditingController();
    final tasksController = TextEditingController();
    final reservationController = TextEditingController();
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAgendaTitle(agenda),
        const SizedBox(height: 6.0),
        ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: List.generate(agenda?.agendaDetails?.length ?? 0, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Text('$index'),
                  const SizedBox(width: 6,),
                  Flexible(
                    child: SizedBox(
                      height: 100,
                      child: TextFormField(
                        controller: summaryController,
                        maxLines: null,
                        expands: true,
                        validator: (val) => val != null && val.isEmpty ? 'please enter Summary of Discussion' : null,
                        style: const TextStyle(fontSize: 17,color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal,)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              )
                          ),
                          hintText: "Summary of Discussion",
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        ),
                        onFieldSubmitted: (_) => saveForm(),
                      ),
                    ),
                  ) ,
                  const SizedBox(width: 6,),
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: TextFormField(
                        controller: tasksController,
                        maxLines: null,
                        expands: true,
                        validator: (val) => val != null && val.isEmpty ? 'please enter Tasks' : null,
                        style: const TextStyle(fontSize: 17),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal,)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              )
                          ),
                          hintText: "Summary of Tasks",
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        ),
                        onFieldSubmitted: (_) => saveForm(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: TextFormField(
                        controller: reservationController,
                        maxLines: null,
                        expands: true,
                        validator: (val) => val != null && val.isEmpty ? 'please enter Reservations' : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal,)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              )
                          ),
                          hintText: "Summary of Reservations",
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        ),
                        onFieldSubmitted: (_) => saveForm(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  Column(
                    children: [
                      FloatingActionButton.extended(
                          heroTag: "btn1${i+1}",
                          label: CustomText(text: AppLocalizations.of(context)!.update_details,color: Colors.white), // <-- Text
                          backgroundColor: Colors.red,
                          icon: const Icon(Icons.add,size: 25.0,color: Colors.white),
                          onPressed: () {
                            print(i);
                            final isValid = updateMinutesDetailsFormGlobalKey.currentState!.validate();
                            agendaList!.add(
                                AgendaDetails(
                                    index: i,
                                    agendaId: agenda.agendaId,
                                    missions: summaryController.text,
                                    tasks: tasksController.text,
                                    reservations: reservationController.text
                                )
                            );
                            var removedDuplicatedData = agendaList.toSet().toList();
                            List<Map<String, dynamic>> detailsFilter = [];
                            for (int i = 0; i < removedDuplicatedData.length; i++) {
                              detailsFilter.add({
                                "agenda_id": removedDuplicatedData[i].agendaId,
                                "missions": removedDuplicatedData[i].missions,
                                "tasks": removedDuplicatedData[i].tasks,
                                "reservations": removedDuplicatedData[i].reservations,
                              });
                            }
                            details = detailsFilter;
                          }
                      ),
                      const SizedBox(height: 6,),
                      TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                          onPressed: (){
                            agendaList.removeWhere((element) => element.index == i,);
                            details.removeWhere((element) => element['agenda_id'] == agenda.agendaId);
                          }, child: CustomText(text: AppLocalizations.of(context)!.remove_details,color: Colors.white,)
                      )
                    ],
                  )
                ],
              ),
            );
          }),
        )
      ],
    );
  }

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: const Icon(Icons.done),
      label: CustomText(text: AppLocalizations.of(context)!.save),
    )
  ];

  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    final isValid = updateMinutesDetailsFormGlobalKey.currentState!.validate();
    if(isValid){
      Map<String, dynamic> data = {
        "listOfAgendaDetails": details,
        "minute_id": widget.minute.minuteId,
      };
      final provider = Provider.of<MinutesProviderPage>(context,listen: false);
      Future.delayed(Duration.zero, () {
        provider.updateMinute(data);
      });
      if(provider.isBack == true){
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: CustomText(text: AppLocalizations.of(context)!.agenda_add_successfully),
              backgroundColor: Colors.greenAccent,
            ),
        );
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.pushReplacementNamed(context, MinutesMeetingList.routeName);
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: CustomText(text: AppLocalizations.of(context)!.agenda_add_failed),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  buildAgendaTitle(agenda){
    return CustomText(text: agenda.agendaTitle!,fontSize: 20.0,fontWeight: FontWeight.bold,);
  }

  buildMinuteTitle(Minute minute) {
    return CustomText(text: minute.minuteName!,fontSize: 20.0,fontWeight: FontWeight.bold,);
  }

}
