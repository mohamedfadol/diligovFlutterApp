import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../NetworkHandler.dart';
import '../../models/user.dart';
import '../../utility/find_text.dart';
import '../../utility/signature_view.dart';
import '../../widgets/date_format_text_form_field.dart';
import '../../widgets/stand_text_form_field.dart';

import '../boards_views/boards_list_views.dart';
import '../boards_views/quick_access_board_list_view.dart';
import '../committee_views/committee_list.dart';
import '../committee_views/quick_access_committee_list_view.dart';
import '../pdfTron/pdf_tron.dart';
import 'members_view/members_list.dart';
import 'members_view/quick_access_member_list_view.dart';

class MemberAndCommittees extends StatefulWidget {
  const MemberAndCommittees({Key? key}) : super(key: key);
  static const routeName = '/MemberAndCommittees';
  @override
  State<MemberAndCommittees> createState() => _MemberAndCommitteesState();
}

class _MemberAndCommitteesState extends State<MemberAndCommittees> {

  final insertBoardFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late String _business_id;


  late List _listOfBoardsData = [];
  String? _board="";
  Future getListBoards() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'] ;
      setState((){
        _listOfBoardsData = boardsData['boards'];
        log.d(_listOfBoardsData);
      });

    } else {
      print(json.decode(response.body)['message']);
    }

  }

  String? _fileBase64 ;
  String? _fileName ;
  FilePickerResult? result;
  String? _fileNameNew;
  PlatformFile? pickedfile;
  File? fileToDisplay;
  bool isLoading = false;
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
        pickedfile = result!.files.first;
        _fileName = pickedfile!.path!;
        print("file name $_fileNameNew");
        print("file pickedfile with path $_fileName");
        print("file fileToDisplay $fileToDisplay");
      }

      setState(() {
        isLoading = false;
      });
    }catch(e){
      print(e);
    }
  }

  TextEditingController _search = TextEditingController();
  TextEditingController boardStartDate = TextEditingController();
  TextEditingController endFiscalYear = TextEditingController();
  TextEditingController _commiteeName = TextEditingController();
  TextEditingController _boardName = TextEditingController();


  // Initial Selected Value
  String dropdownvalue = '51';
  // List of items in our dropdown menu
  var items = ['51','66','70'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    boardStartDate.text = "";
    endFiscalYear.text = "";
    _commiteeName.text = "";
    _boardName.text = "";
    _fileNameNew = "";
    _fileName = "";

    Future.delayed(Duration.zero, (){
      getListBoards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 40.0,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                label: const Text('Board',style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add,color: Colors.red,size: 40.0),
                onPressed: () {openBoardCreateDialog();},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.0)
                ),
              ),
              SizedBox(width: 15.0),
              ElevatedButton.icon(
                label: const Text('View List Of Board',style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.arrow_circle_right_outlined,color: Colors.red,size: 25.0),
                onPressed: () { Navigator.pushReplacementNamed(context, QuickAccessBoardListView.routeName); },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 5.0)
                ),
              ),
            ],
          ),

          // const SizedBox(height:30.0),
          Row(
            children: [
              ElevatedButton.icon(
                label: const Text('Committee',style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add,color: Colors.red,size: 40.0),
                onPressed: () {openCommitteeCreateDialog();},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.0)
                ),
              ),

              SizedBox(width: 15.0),
              ElevatedButton.icon(
                label: const Text('View List Of Committee',style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.arrow_circle_right_outlined,color: Colors.red,size: 25.0),
                onPressed: () { Navigator.pushReplacementNamed(context, QuickAccessCommitteeListView.routeName); },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 5.0)
                ),
              ),
            ],
          ),
          // const SizedBox(height:30.0),
          Row(
            children: [
              ElevatedButton.icon(
                label: const Text('Members',style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add,color: Colors.red,size: 40.0,),
                onPressed: () {Navigator.pushReplacementNamed(context, QuickAccessMemberListView.routeName);},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.0,)
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }




  Future  openCommitteeCreateDialog() => showDialog(
      context: context,
      builder:  (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100.0),
                title: const Text("Add New Committee",style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold)),
                content: Form(
                  key: insertBoardFormGlobalKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                        color: Colors.black12,
                        width: MediaQuery.of(context).size.width*0.45,
                        child: Column(
                          children: [
                            StandTextFormField(
                              color: Colors.redAccent,
                              icon: Icons.people,
                              labelText: "Committee Name",
                              valid: (val){
                                if (val!.isNotEmpty ) {
                                  return null;
                                } else {
                                  return 'Enter a valid committee Name';
                                }
                              },
                              controllerField: _commiteeName,
                            ),
                            const SizedBox(height:15),
                            Container(
                              constraints: const BoxConstraints(minHeight: 30.0),
                              padding: EdgeInsets.all(7),
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius:  BorderRadius.circular(10.0),
                                  color: Colors.white38,
                                  boxShadow:  const [
                                    BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                                  ]),
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
                                  value: _board,
                                  icon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
                                  // Array list of items
                                  items:[
                                    const DropdownMenuItem(
                                      value: "",
                                      child: Text("Select an Board",style: TextStyle(color: Colors.black)),
                                    ),
                                    ..._listOfBoardsData!.map((item){
                                      return DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: Text(item['board_name'],style: const TextStyle(color: Colors.black)),
                                      );
                                    }).toList(),
                                  ]
                                  ,
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (String? newValue) {
                                    _board = newValue!.toString();
                                    setState(() {
                                      _board = newValue!;
                                    });
                                    print(_board);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height:12),
                            imageProfile(),
                            const SizedBox(height:15),
                            InkWell(
                                onTap: () async{
                                  pickedFile();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right:10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:  BorderRadius.circular(0.0),
                                  ),
                                  child: const Text('Upload Charter',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
                                )
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        ElevatedButton.icon(
                          onPressed: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            user = User.fromJson(json.decode(prefs.getString("user")!)) ;
                            setState((){
                              isLoading = true;
                              _business_id = user.businessId.toString();
                            });
                            if (insertBoardFormGlobalKey.currentState!.validate()) {
                              insertBoardFormGlobalKey.currentState!.save();
                              if (pickedfile != null) {
                                final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
                                setState(() {
                                  _fileBase64 = fileBase64;
                                });
                              }

                              Map<String, String> data = {
                                "committee_name": _commiteeName.text,'charter_committee': _fileNameNew!,'fileSelf': _fileBase64!,
                                "board_id": _board!,"business_id": _business_id
                              };
                              var response = await networkHandler.post("/insert-new-committee", data);
                              if (response.statusCode == 200 || response.statusCode == 201) {
                                log.d("insert-new-committee response statusCode == 200");
                                var responseData = json.decode(response.body);
                                var committeeData = responseData['data'];
                                Navigator.pop(context);

                                Flushbar(
                                  title: "Create Committee has been Successfully",
                                  message: json.decode(response.body)['message'].toString(),
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.greenAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              } else {
                                print(response.statusCode);
                                print(json.decode(response.body)['message']);
                                Flushbar(
                                  title: "Create Board has been Faild",
                                  message: json.decode(response.body)['message'].toString(),
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.redAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              }
                            }
                          },
                          icon: const Icon(Icons.add,size: 30,color: Colors.white,),
                          label: const Text('Add Committee',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
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



  Future openBoardCreateDialog() => showDialog(
      context: context,
      builder:  (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: const Text("Add New Board",style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold)),
                content: Form(
                  key: insertBoardFormGlobalKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                        color: Colors.black12,
                        width: MediaQuery.of(context).size.width*0.45,
                        child: Column(
                          children: [
                            StandTextFormField(
                              color: Colors.redAccent,
                              icon: Icons.people,
                              labelText: "Board Name",
                              valid: (val){
                                if (val!.isNotEmpty ) {
                                  return null;
                                } else {
                                  return 'Enter a valid Board Name';
                                }
                              },
                              controllerField: _boardName,
                            ),
                            const SizedBox(height:15),

                            DateFormatTextFormField(
                              dateinput: boardStartDate, labelText: "Start Board Date",
                              onTap: (){onTapGetDate(boardStartDate);},
                              icon: Icons.calendar_today,color: Colors.redAccent,
                            ),
                            const SizedBox(height:15),
                            const Text("Set Quorum etc: ( 51% - 66% - 70% ) this decides resolution approval",
                                style: TextStyle(color: Colors.black)),
                            const SizedBox(height:10),
                            DropdownButton(
                              hint: const Text("Set Quorum etc: ( 51% - 66% - 70% ) this decides resolution approval",
                                  style: TextStyle(color: Colors.black)),
                              dropdownColor: Colors.white60,
                              focusColor: Colors.redAccent[300],
                              // Initial Value
                              value: dropdownvalue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              // Array list of items
                              items: items.map((String item)
                              => DropdownMenuItem(
                                value: item,
                                child: Text("% $item"),
                              )).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                });
                                print(dropdownvalue);
                              },
                            ),
                            const SizedBox(height:15),
                            DateFormatTextFormField(
                              dateinput: endFiscalYear,
                              labelText: "Set Financial Year End",
                              onTap: (){ onTapGetDate(endFiscalYear);},
                              icon: Icons.calendar_today,color: Colors.redAccent,
                            ),
                            const SizedBox(height:15),
                            imageProfile(),
                            const SizedBox(height:15),
                            InkWell(
                                onTap: () { pickedFile(); },
                                child: Container(
                                  margin: EdgeInsets.only(right:10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:  BorderRadius.circular(0.0),
                                  ),
                                  child: const Text('Upload Charter',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
                                )
                            ),

                          ],
                        )
                    ),
                  ),
                ),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        ElevatedButton.icon(
                          label: const Text('Add Board',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold),),
                          icon: const Icon(Icons.add,color: Colors.white),
                          onPressed: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            user = User.fromJson(json.decode(prefs.getString("user")!)) ;
                            setState((){
                              isLoading = true;
                              _business_id = user.businessId.toString();
                            });
                            if (insertBoardFormGlobalKey.currentState!.validate()) {
                              insertBoardFormGlobalKey.currentState!.save();
                              if (pickedfile != null) {
                                final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
                                setState(() {
                                  _fileBase64 = fileBase64;
                                });
                              }
                              Map<String, String> data = {
                                "term": boardStartDate.text,
                                "quorum": dropdownvalue,
                                "fiscal_year": endFiscalYear.text,
                                "board_name": _boardName.text,
                                "charter_board": _fileNameNew!,
                                "fileSelf": _fileBase64!,
                                "business_id": _business_id
                              };
                              print(data);
                              var response = await networkHandler.post("/insert-new-board", data);
                              if (response.statusCode == 200 || response.statusCode == 201) {

                                log.d("insert-new-board response statusCode == 200");
                                var responseData = json.decode(response.body);
                                // var boardData = responseData['data'];

                                // var board = Board.fromJson(boardData['board']);
                                // print(board);
                                Navigator.pop(context);
                                Flushbar(
                                  title: "Create Board",
                                  message: "Create Board has been Successfully",
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.greenAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              } else{
                                log.d(response.statusCode);
                                print(json.decode(response.body)['message']);
                                Flushbar(
                                  title: "Create Board has been Faild",
                                  message: json.decode(response.body)['message'].toString(),
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.redAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              }
                            }
                          },
                          // style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.transparent,
                          //     padding: EdgeInsets.symmetric(horizontal: 10.0)
                          // ),
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


  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.brown.shade800,
              radius: 50.0,
              child: pickedfile == null ? Icon(Icons.upload_file ,size: 24.0,) : Text(pickedfile!.name,style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );
  }


}
