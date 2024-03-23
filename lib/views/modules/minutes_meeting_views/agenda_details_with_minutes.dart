import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/agenda_details.dart';
import '../../../models/agenda_model.dart';
import '../../../models/user.dart';
import '../../../providers/minutes_provider_page.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/loading_sniper.dart';
import 'minutes_meeting_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class AgendaDetailsWithMinutes extends StatefulWidget {
  final String? meetingId;
  const AgendaDetailsWithMinutes({Key? key,required this.meetingId}) : super(key: key);

  @override
  State<AgendaDetailsWithMinutes> createState() => _AgendaDetailsWithMinutesState();
}

class _AgendaDetailsWithMinutesState extends State<AgendaDetailsWithMinutes> {
  final insertMinutesDetailsFormGlobalKey = GlobalKey<FormState>();

  final List<TextEditingController> _attended_name = [];
  final List<TextEditingController> _position = [];

  User user = User();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  List<AgendaDetails> agendaList =[];

  Agendas? _listOfAgendaData;
  Future getListAgendas() async{
    Map<String,String> data = {"meeting_id": widget.meetingId!};
    var response = await networkHandler.get('/get-list-agenda-by-meetingId/${data["meeting_id"]}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-agendas response statusCode == 200");
      var responseData = json.decode(response.body);
      var agendasData = responseData['data'];
      _listOfAgendaData = Agendas.fromJson(agendasData);
      setState((){
        _listOfAgendaData = Agendas.fromJson(agendasData);
      });
    } else {
      log.d("get-list-agendas response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addField();
    });
    Future.delayed(Duration.zero, (){
      getListAgendas();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _addField(){
    setState(() {
      _attended_name.add(TextEditingController());
      _position.add(TextEditingController());
    });
  }

  _removeItem(i){
    setState(() {
      _attended_name.removeAt(i);
      _position.removeAt(i);
    });
  }


  void onStepCancel() {
    if (_index > 0) {
      setState(() {
        _index -= 1;
      });
    }
  }

  void onStepContinue() {
    if (_index <= 0) {
      setState(() {
        _index += 1;
      });
    }
  }

  Widget buildAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: (){
          _addField();
        },
        child: const Icon(Icons.add,size:35,color: Colors.grey,),
      ),
    ],
  );

  Widget buildRemoveAtButton(index) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        child: const Icon(Icons.remove_circle_outline,color: Colors.red,),
        onTap: (){
          print("remove $index");
          _removeItem(index);
        },
      ),
    ],
  );


  List<Map<String, dynamic>> details =[];
  int _index = 0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: const CloseButton(),
          actions: buildEditingActions(),
        ),
        body:  _listOfAgendaData?.agendas == null ? buildLoadingSniper()  :  _listOfAgendaData!.agendas!.isEmpty ?
        buildEmptyMessage(AppLocalizations.of(context)!.there_no_agendas_add_selected_meeting_please_fill_it) :
        Form(
          key: insertMinutesDetailsFormGlobalKey,
          child: Stepper(
            controlsBuilder: (BuildContext context, ControlsDetails details){
              return Row(
                children: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: onStepContinue,
                    child: const Text('next',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(width: 10,),
                  TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: onStepCancel,
                    child: const Text('back',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  ),
                ],
              );
            },
            elevation: 0.0,
            type: StepperType.horizontal,
            currentStep: _index,
            onStepTapped: (int index) {
              setState(() {
                _index = index;
              });
            },
            steps: <Step>[
              Step(
                state: _index > 0 ? StepState.complete : StepState.indexed,
                isActive: _index >= 0,
                title: const Text('agenda_details'),
                content: Column(
                  children: [
                    SizedBox(
                      height: 500,
                      child: ListView.builder(
                          itemCount: _listOfAgendaData!.agendas!.length!,
                          itemBuilder: (BuildContext context,int index){
                            final Agenda  agenda = _listOfAgendaData!.agendas![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15.0),
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: [
                                  CustomText(text:'${agenda.agendaTitle}',fontWeight: FontWeight.bold,fontSize: 20.0,color: Colors.black,),
                                  const SizedBox(height: 5.0,),
                                  const SizedBox(width: 6,),
                                  agendaDetailsForm(index,agenda),
                                  const SizedBox(height: 8.0,),
                                ],
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                state: _index > 1 ? StepState.complete : StepState.indexed,
                isActive: _index >= 1,
                title: const Text('attendance from abroad'),
                content: Column(
                  children: [
                    buildAddButton(),
                    const SizedBox(height: 10,),
                    for(int i = 0; i < _attended_name.length; i++)
                      Column(
                        children: [
                          buildRemoveAtButton(i),
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(5.0),
                                  color: Colors.white10,
                                  child: Text('${i+1}')
                              ),
                              const SizedBox(width: 6,),
                              Expanded(
                                child: SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    maxLines: null,
                                    expands: true,
                                    controller: _attended_name[i],
                                    validator: (val) => val != null && val.isEmpty ? 'please enter title name' : null,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: 'Title Name',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                    ),
                                  ),
                                ),
                              ) ,
                              const SizedBox(width: 6,),
                              Expanded(
                                child: SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    maxLines: null,
                                    expands: true,
                                    controller: _position[i],
                                    validator: (val) => val != null && val.isEmpty ? 'please enter his position' : null,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: 'Position',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0,)
                        ],
                      )
                  ],
                ),
              ),
            ],
          ),
        )

    );
  }

  buildEmptyMessage(String message) {
    return CustomMessage(text: message,);
  }

  buildLoadingSniper(){
    return const LoadingSniper();
  }

  agendaDetailsForm(int index,Agenda agenda) {
    final summaryController = TextEditingController();
    final tasksController = TextEditingController();
    final reservationController = TextEditingController();
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$index'),
        const SizedBox(width: 6,),
        Expanded(
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
        FloatingActionButton.extended(
          heroTag: "btn${index+1}",
          label: CustomText(text: AppLocalizations.of(context)!.add_details,color: Colors.white),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.add,size: 25.0,color: Colors.white),
            onPressed: () {
              final isValid = insertMinutesDetailsFormGlobalKey.currentState!.validate();
              if(agenda.agendaDetails==null) {
                agendaList!.add(
                    AgendaDetails(
                        index: index,
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
                print(detailsFilter);
                print(removedDuplicatedData);
                print(details);
              }
            }
        ),
      ],
    );
  }

  void onTapGetDate  (TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    if(pickedDate != null ){
      print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      print(formattedDate); //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        passDate.text = formattedDate; //set output date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: const Icon(Icons.done),
      label: Text(AppLocalizations.of(context)!.save_minute,style: TextStyle(color: Colors.white)),
    )
  ];

  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> attendanceBoard =[];
    final isValid = insertMinutesDetailsFormGlobalKey.currentState!.validate();
    // if(isValid){
      if(_attended_name.isNotEmpty){
        for(int i =0; i < _attended_name.length; i++){
          attendanceBoard.add({
            "attended_name": _attended_name[i].text,
            "position": _position[i].text,
          });
        }
      }
      Map<String, dynamic> data = {
        "listOfAgendaDetails": details,
        "attendance": attendanceBoard,
        "meeting_id": widget.meetingId,
        "business_id": user.businessId,
        "add_by": user.userId
      };
      final provider = Provider.of<MinutesProviderPage>(context,listen: false);
      Future.delayed(Duration.zero, () {
        provider.insertMinute(data);
        provider.setIsBack(true);
      });

      if(provider.isBack == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: AppLocalizations.of(context)!.agenda_add_successfully ),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Future.delayed(const Duration(seconds: 10), () {
          Navigator.pushReplacementNamed(context, MinutesMeetingList.routeName);
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: AppLocalizations.of(context)!.agenda_add_failed ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    // }
  }



  }


