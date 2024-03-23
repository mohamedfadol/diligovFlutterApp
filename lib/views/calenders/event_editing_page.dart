import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../NetworkHandler.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/meeting_model.dart';
import '../../models/user.dart';
import '../../providers/meeting_page_provider.dart';
import '../../utility/utils.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CommitteeEventEditingPage extends StatefulWidget {
  final Meeting? event;
  const CommitteeEventEditingPage({Key? key, this.event}) : super(key: key);

  @override
  State<CommitteeEventEditingPage> createState() => _CommitteeEventEditingPageState();
}

class _CommitteeEventEditingPageState extends State<CommitteeEventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final videoConferenceLinkController = TextEditingController();
  final conferenceLinkController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;
  var  meetingId;
  User user = User();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;

  String? _fileBase64 ;
  String? _fileName ;
  FilePickerResult? result;
  String? _fileNameNew;
  PlatformFile? pickedFormFile;
  File? fileToDisplay;
  void pickedFile() async {
    try{
      setState(() {
        isLoading = true;
      });

      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf']
      );
      if(result != null){
        _fileNameNew = result!.files.first.name;
        pickedFormFile = result!.files.first;
        _fileName = pickedFormFile!.path!;
        print("file name $_fileNameNew");
        print("file pickedFormFile with path $_fileName");
        print("file fileToDisplay $fileToDisplay");
      }

      setState(() {
        isLoading = false;
      });
    }catch(e){
      print(e);
    }
  }

  final List<TextEditingController> _title = [];
  final List<TextEditingController> _description = [];
  final List<TextEditingController> _time = [];
  final List<TextEditingController> _user = [];


  late List _listOfCommitteeData = [];
  String? committee="";
  Future getListCommittees() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-committees/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-committees response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var committeesData = responseData['data'] ;
      setState((){
        _listOfCommitteeData =  committeesData['committees'];
        print(_listOfCommitteeData);
      });
    } else {
      log.d("get-list-committees response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  late List _listOfBoardsData = [];
  String? board="";
  Future getListBoards() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler.get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'] ;
      setState((){
        _listOfBoardsData = boardsData['boards'];
        // log.d(_listOfBoardsData);
      });
    } else {
      log.d("get-list-boards response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  List _membersListIds = [];
  List _selectedMembers = [];

  late List _listOfMembersData = [];
  String? member="";
  Future getListMembers() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'] ;
      setState((){
        _listOfMembersData =  membersData['members'];
        print(_listOfMembersData);
      });
    } else {
      log.d("get-list-members response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedMembers = [];
    _membersListIds = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addField();
    });
    Future.delayed(Duration.zero, (){
      getListCommittees();
      getListMembers();
      getListBoards();
    });
    if(widget.event == null){
      fromDate = DateTime.now();
      toDate = DateTime.now().add(const Duration(hours: 2));
    }else{
      final event = widget.event!;
      meetingId = event.meetingId!;
      titleController.text = event.meetingTitle!;
      fromDate =event.meetingStart!;
      toDate = event.meetingEnd!;
      descriptionController.text = event.meetingDescription!;
      videoConferenceLinkController.text = event.meetingMediaName!;
      conferenceLinkController.text = event.meetingBy!;
    }
  }

  _addField(){
    setState(() {
      _title.add(TextEditingController());
      _description.add(TextEditingController());
      _time.add(TextEditingController());
      _user.add(TextEditingController());
    });
  }

  _removeItem(i){
    setState(() {
      _title.removeAt(i);
      _description.removeAt(i);
      _time.removeAt(i);
      _user.removeAt(i);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    videoConferenceLinkController.dispose();
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
    body: Form(
      key: _formKey,
      child: Stepper(
        controlsBuilder: (BuildContext context, ControlsDetails details){
          return Row(
            children: <Widget>[
              TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: onStepContinue,
                child: const Text('Next',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
              const SizedBox(width: 10,),
              TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: onStepCancel,
                child: const Text('Back',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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
            title: const Text('meeting content'),
            content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildBoardDropdown(),
                    const SizedBox(height: 15,),
                    buildTitle(),
                    const SizedBox(height: 15,),
                    buildDescription(),
                    const SizedBox(height: 15,),
                    buildDateTimePickers(),
                    const SizedBox(height: 15,),
                    buildVideoConferenceLink()
                  ],
                ),
          ),
           Step(
            state: _index > 1 ? StepState.complete : StepState.indexed,
            isActive: _index >= 1,
            title: const Text('agenda content'),
            content: Column(
              children: [
                 buildAddButton(),
                const SizedBox(height: 10,),
                for(int i = 0; i < _title.length; i++)
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
                           Flexible(
                             child: SizedBox(
                               height: 100,
                               child: Column(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          maxLines: null,
                                          expands: true,
                                          controller: _title[i],
                                          validator: (val) => val != null && val.isEmpty ? 'please enter title' : null,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            hintText: 'Title',
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                          ),
                                        ),
                                      ),
                                       Row(
                                          children: [
                                            Expanded(
                                              child:InkWell(
                                                onTap: () async{
                                                  pickedFile();
                                                },
                                                child: imageProfile()
                                            )),
                                            const SizedBox(width: 10.0,),
                                            Expanded(
                                              child:IconButton(
                                              onPressed: (){
                                                openMemberSearchBoxDialog();
                                              },
                                              icon: const Icon(Icons.add,color: Colors.green,size: 30,),
                                            ))
                                          ],
                                        ),
                                    ],
                                ),
                             ),
                           ) ,
                          const SizedBox(width: 6,),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: TextFormField(
                                maxLines: null,
                                expands: true,
                                controller: _description[i],
                                validator: (val) => val != null && val.isEmpty ? 'please enter description' : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: 'Description',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6,),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: TextFormField(
                                maxLines: null,
                                expands: true,
                                controller: _time[i],
                                validator: (val) => val != null && val.isEmpty ? 'please enter time' : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: 'Time',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6,),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: TextFormField(
                                maxLines: null,
                                expands: true,
                                controller: _user[i],
                                validator: (val)=> val != null && val.isEmpty ? 'please enter presenter' : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: 'Presenter',
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
      )
    ),
  );

  Future openMemberSearchBoxDialog() => showDialog(
  context: context,
  builder:  (BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 100),
            title: const Text("Signature Request Deloitte Audit Committee Practices.PDF",style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 600,
              child: Form(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      padding : const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                      color: Colors.black12,
                      width: MediaQuery.of(context).size.width*0.45,
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0,),
                          Container(
                            constraints: const BoxConstraints(minHeight: 15.0),
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius:  BorderRadius.circular(10.0),
                                color: Colors.white,
                                boxShadow:  const [
                                  BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                                ]),
                            child: MultiSelectDialogField<dynamic>(
                              confirmText: const Text('add Members',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                              cancelText: const Text('cancel',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                              separateSelectedItems: true,
                              buttonIcon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.black),
                              title: const Text("Members List"),
                              buttonText: const Text("Select Multiple Members To Signed",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold)),
                              items: _listOfMembersData!
                                  .map((member) => MultiSelectItem<dynamic>(member, member['member_first_name']!))
                                  .toList(),
                              searchable: true,
                              validator: (values) {
                                if (values == null || values.isEmpty) {
                                  return "Required";
                                }
                                List members = values.map((member) => member['id']).toList();
                                if (members.contains("member_first_name")) {
                                  return "Member are weird!";
                                }
                                return null;
                              },
                              onConfirm: (values) {
                                setState(() {
                                  _selectedMembers = values;
                                  _membersListIds = _selectedMembers.map((e) => e['id']).toList();
                                  print(_membersListIds);
                                });
                              },
                              chipDisplay: MultiSelectChipDisplay(
                                onTap: (item) {
                                  setState(() {
                                    _selectedMembers.remove(item);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ),
            actions: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    ElevatedButton.icon(
                      label: const Text('Add List of Members',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold),),
                      icon: const Icon(Icons.add,color: Colors.white),
                      onPressed: () async {

                      },
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ]
              ),
            ],
          );
        }
    );
  }
  );

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: const Icon(Icons.done),
      label: const Text('Save'),
    )
  ];

  Widget buildTitle() =>  TextFormField(
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
      hintText: "Meeting Title",
    ),
    validator: (meetingTitle) =>
      meetingTitle != null && meetingTitle.isEmpty ? 'Meeting Title cannot be empty' : null
    ,
    onFieldSubmitted: (_) => saveForm(),
    controller: titleController,
  );

  Widget buildVideoConferenceLink() =>  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: TextFormField(
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
            hintText: "Meeting Video Conference Link",
          ),
          validator: (videoConferenceLink) =>
          videoConferenceLink != null && videoConferenceLink.isEmpty ? 'Meeting Video Conference Link cannot be empty' : null
          ,
          onFieldSubmitted: (_) => saveForm(),
          controller: videoConferenceLinkController,
        ),
      ),
      const SizedBox(width:10),
      Expanded(
        child: TextFormField(
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
            hintText: "Conference Link",
          ),
          validator: (conferenceLink) =>
          conferenceLink != null && conferenceLink.isEmpty ? 'Meeting Conference Link cannot be empty' : null
          ,
          onFieldSubmitted: (_) => saveForm(),
          controller: conferenceLinkController,
        ),
      ),
    ],
  );

  Widget buildDescription() =>  TextFormField(
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
      hintText: "Meeting Description",
    ),
    validator: (meetingDescription) =>
    meetingDescription != null && meetingDescription.isEmpty ? 'Meeting Description cannot be empty' : null
    ,
    onFieldSubmitted: (_) => saveForm(),
    controller: descriptionController,
  );

  Widget buildDateTimePickers() => Column(
    children: [
      const SizedBox(height: 15,),
      buildForm(),
      const SizedBox(height: 15,),
      buildTo()
    ],
  );

  Widget buildBoardDropdown() => Container(
    constraints: const BoxConstraints(minHeight: 30.0),
    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
    decoration: BoxDecoration(
        borderRadius:  BorderRadius.circular(10.0),
        color: Colors.red,
        boxShadow:  const [
          BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
        ]
    ),
    child: DropdownButtonHideUnderline(
  child: DropdownButton(
    isExpanded: true,
    isDense: true,
    menuMaxHeight: 300,
    style: Theme.of(context).textTheme.headline6,
    hint: const Text("Select an Board",style: TextStyle(color: Colors.white)),
    dropdownColor: Colors.white60,
    focusColor: Colors.redAccent[300],
    // Initial Value
    value: board,
    icon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
    // Array list of items
    items:[
      const DropdownMenuItem(
        value: "",
        child: Text("Select an Board",style: TextStyle(color: Colors.white)),
      ),
      ..._listOfBoardsData!.map((item){
        return DropdownMenuItem(
          value: item['id'].toString(),
          child: Text(item['board_name'],style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
    ],
    // After selecting the desired option,it will
    // change button value to selected value
    onChanged: (String? newValue) {
      board = newValue?.toString();
      setState(() {
        board = newValue!;
      });
    },
  ),
    ),
  );

  Widget buildCommitteeDropdown() => Container(
    constraints: const BoxConstraints(minHeight: 30.0),
    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
    decoration: BoxDecoration(
        borderRadius:  BorderRadius.circular(10.0),
        color: Colors.red,
        boxShadow:  const [
          BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
        ]
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton(
        isExpanded: true,
        isDense: true,
        menuMaxHeight: 300,
        style: Theme.of(context).textTheme.headline6,
        hint: const Text("Select an Committee",style: TextStyle(color: Colors.white)),
        dropdownColor: Colors.white60,
        focusColor: Colors.redAccent[300],
        // Initial Value
        value: committee,
        icon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
        // Array list of items
        items:[
          const DropdownMenuItem(
            value: "",
            child: Text("Select an Committee",style: TextStyle(color: Colors.white)),
          ),
          ..._listOfCommitteeData!.map((item){
            return DropdownMenuItem(
              value: item['id'].toString(),
              child: Text(item['committee_name'],style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
        ],
        // After selecting the desired option,it will
        // change button value to selected value
        onChanged: (String? newValue) {
          committee = newValue?.toString();
          setState(() {
            committee = newValue!;
          });
        },

      ),

    ),
  );

  Widget buildForm() => buildHeader(
    header: 'Meeting Start DateTime',
    child: Row(
      children: [
        Expanded(
          flex: 2,
            child: buildDropdownField(
              text: Utils.toDate(fromDate),
              onClicked: () => pickFromDateTime(pickDate: true),
            )
        ),
        Expanded(
            child: buildDropdownField(
              text: Utils.toTime(fromDate),
              onClicked: () => pickFromDateTime(pickDate: false),
            )
        )
      ],
    ),
  );

  Widget buildTo() => buildHeader(
    header: 'Meeting End DateTime',
    child: Row(
      children: [
        Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toDate(toDate),
              onClicked: ()=> pickToDateTime(pickDate: true),
            )
        ),
        Expanded(
            child: buildDropdownField(
              text: Utils.toTime(toDate),
              onClicked: ()=> pickToDateTime(pickDate: false),
            )
        )
      ],
    ),
  );

  Widget buildDropdownField({required text, required VoidCallback onClicked})=>
      ListTile(title: Text(text),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({required String header, required Widget child,}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(fontWeight: FontWeight.bold),),
          child,
        ],
      );

  Widget imageProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top:3.0),
        child: Container(
            width: 130,
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 3.0),
            child: pickedFormFile == null ? Icon(Icons.upload_file ,size: 24.0,color: Colors.white,) : Text(pickedFormFile!.name,style: TextStyle(color: Colors.white),)
        ),
      ),
    );
  }


  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> agendas =[];
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      if(_title.isNotEmpty){
        for(int i =0; i < _title.length; i++){
          if (pickedFormFile != null) {
            final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
            setState(() {
              _fileBase64 = fileBase64;
            });
          }
          agendas.add({
              "agenda_title": _title[i].text,
              "agenda_description": _description[i].text,
              "agenda_time": _time[i].text,
              "agenda_file": _fileNameNew!,
              'fileSelf': _fileBase64!,
              "presenter_id": _user[i].text,
              "created_by": user.userId
            });
        }
      }
      // log.i(agendas);
      Map<String, dynamic> event = {
        "meeting_id": meetingId,
        "board_id": board,
        "committee_id": committee,
        "created_by": user.userId,
        "meeting_title": titleController.text,
        "meeting_description": descriptionController.text,
        "meeting_media_name" : videoConferenceLinkController.text,
        "meeting_by" : conferenceLinkController.text,
        "meeting_start": fromDate.toString(),
        "meeting_end": toDate.toString(),
        "listOfAgendas": agendas,
        "membersSignedIds": _membersListIds,
        "business_id": user.businessId
      };
      final isEditing = widget.event != null;
      final provider = Provider.of<MeetingPageProvider>(context,listen: false);
      if(isEditing){
        provider.editingMeeting(event, widget.event!);
        Navigator.of(context).pop();
      }else{
        provider.insertMeeting(event);
        Navigator.of(context).pop();
      }


    }
  }

  Future pickFromDateTime({required bool pickDate}) async{
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if(date == null) return;
    if(date.isAfter(toDate)){
      toDate = DateTime(date.year,date.month,date.day,toDate.hour,toDate.minute);
    }
    setState(()  => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async{
    final date = await pickDateTime(
        toDate,
        pickDate: pickDate,
        firstDate: pickDate ? fromDate : null
    );
    if(date == null) return;

    setState(()  => toDate = date);
  }


  Future<DateTime?> pickDateTime(
      DateTime initialDate,{
    required bool pickDate,
    DateTime? firstDate,}) async{
    if(pickDate){
      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate ?? DateTime(2015, 8),
                        lastDate: DateTime(2101));
      if(date == null) return null;
      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    }else{
      final timeOfDay = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(initialDate));
      if(timeOfDay == null) return null;
      final date = DateTime(initialDate.year, initialDate.month,initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);


    }
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

}


