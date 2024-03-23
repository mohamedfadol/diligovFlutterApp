import 'dart:convert';

import 'package:diligov/providers/meeting_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/agenda_model.dart';
import '../../../models/user.dart';
class TasksReservationsViews extends StatefulWidget {
  final String? meetingId;
  const TasksReservationsViews({Key? key,required this.meetingId}) : super(key: key);

  @override
  State<TasksReservationsViews> createState() => _TasksReservationsViewsState();
}

class _TasksReservationsViewsState extends State<TasksReservationsViews> {
  final insertMinutesDetailsFormGlobalKey = GlobalKey<FormState>();
  User user = User();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  final List<TextEditingController> summaryController = [];
  final List<TextEditingController> tasksDescriptionController = [];
  final List<TextEditingController> reservationsController = [];

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

  _addField(){
    setState(() {
      summaryController.add(TextEditingController());
      tasksDescriptionController.add(TextEditingController());
      reservationsController.add(TextEditingController());
    });
  }

  _removeItem(i){
    setState(() {
      summaryController.removeAt(i);
      tasksDescriptionController.removeAt(i);
      reservationsController.removeAt(i);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List<Map<String,String?>> dis = [] ;
  List<Map<String,String?>> task = [] ;
  List<Map<String,String?>> reservation = [] ;
  List<Map<String, dynamic>> details =[];
  @override
  Widget build(BuildContext context) {
    //provider init
    final meetingProvider = Provider.of<MeetingPageProvider>(context,listen: false);
    meetingProvider.getListAgendas(widget.meetingId!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
      body: listAgenda(context)

    );
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
      label: const Text('Save Minute',style: TextStyle(color: Colors.white)),
    )
  ];

  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> agendas =[];
    // final isValid = insertMinutesDetailsFormGlobalKey.currentState!.validate();
    print(details);
    // if(isValid){
    //   if(summaryController.isNotEmpty){
    //     for(int i =0; i < summaryController.length; i++){
    //       agendas.add({
    //         "agenda_id": _listOfAgendaData!.agendas![i].agendaId!,
    //         "summary_of_discussion": summaryController[i].text,
    //         "tasks": tasksDescriptionController[i].text,
    //         "reservations": reservationsController[i].text,
    //         "created_by": user.userId,
    //         "business_id": user.businessId
    //       });
    //     }
    //   }
    //   print(agendas);
    //   // Map<String, dynamic> event = {
    //   //   "meeting_id": meetingId,
    //   //   "board_id": board,
    //   //   "committee_id": committee,
    //   //   "created_by": user.userId,
    //   //   "meeting_title": titleController.text,
    //   //   "meeting_description": descriptionController.text,
    //   //   "meeting_media_name" : videoConferenceLinkController.text,
    //   //   "meeting_by" : conferenceLinkController.text,
    //   //   "meeting_start": fromDate.toString(),
    //   //   "meeting_end": toDate.toString(),
    //   //   "listOfAgendas": agendas,
    //   //   "membersSignedIds": _membersListIds,
    //   //   "business_id": user.businessId
    //   // };
    //   // final isEditing = widget.event != null;
    //   // final provider = Provider.of<MeetingPageProvider>(context,listen: false);
    //   // if(isEditing){
    //   //   provider.editingMeeting(event, widget.event!);
    //   //   Navigator.of(context).pop();
    //   // }
    //
    //
    // }
  }

  Widget listAgenda(BuildContext context){
    final meetingProvider = Provider.of<MeetingPageProvider>(context,listen: false);
  return  ChangeNotifierProvider<MeetingPageProvider>(
      create: (_) =>MeetingPageProvider(),
      child:
      meetingProvider.listAgenda!.agendas!.isEmpty?
      const   Center(child:CircularProgressIndicator()):
      ListView.builder(
          itemCount: meetingProvider.listAgenda!.agendas!.length,
          itemBuilder:  (BuildContext context,int index){
            return agendaDetails(meetingProvider.listAgenda!.agendas![index]);
          })
    );


  }


  Widget agendaDetails(Agenda agenda){

    return Column(
      children: [
        // _listAgendaDetails(agenda!.agendaDetails),
        _form(agenda),
      ],
    );

  }

  // _listAgendaDetails(AgendaDetails? agendaDetails) {
  //   return agendaDetails == null ? const SizedBox()
  //     : Column(
  //     children:List.generate(agendaDetails, (index) => Row(
  //       children:[
  //         Expanded(child:Text(agendaDetails.missions??'')),
  //         Expanded(child:Text(agendaDetails.tasks??'')),
  //         Expanded(child:Text(agendaDetails.reservations??'')),
  //       ]
  //     ))
  //   );
  // }

  _form(Agenda agenda) {
    //text controller init
    final _textController1 = TextEditingController();
    final _textController2 = TextEditingController();
    final _textController3 = TextEditingController();
  return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 6,),
        Flexible(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: TextFormField(
                  controller: _textController1,
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
            ],
          ),
        ) ,
        const SizedBox(width: 6,),
        Expanded(
          child: SizedBox(
            height: 100,
            child: TextFormField(
              controller: _textController2,
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
              controller: _textController3,
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
        IconButton(onPressed: (){
          if(agenda.agendaDetails==null){
            // agenda.agendaDetails=[];
            // agenda.agendaDetails!.add(
            //     AgendaDetails(
            //       missions: _textController1.text,
            //       tasks: _textController2.text,
            //       reservations: _textController3.text
            //     )
            // );
          }
          print(details);
          // final meetingProvider = Provider.of<MeetingPageProvider>(context,listen: false);
          // meetingProvider.addAgendaDetails(agenda);
          // print(agenda.agendaDetails!.map((e) => e.task));
          // _textController1.clear();
          // _textController2.clear();
          // _textController3.clear();
        }, icon: Icon(Icons.add)),
      ],
    );
  }




}
