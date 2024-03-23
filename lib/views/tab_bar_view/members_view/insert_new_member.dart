import 'dart:convert';
import 'package:diligov/providers/committee_provider.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:diligov/views/tab_bar_view/members_view/members_list.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../../NetworkHandler.dart';
import '../../../models/committee_model.dart';
import '../../../models/member.dart';
import '../../../providers/member_page_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/stand_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user.dart';
class InsertNewMember extends StatefulWidget {
  const InsertNewMember({Key? key}) : super(key: key);
  static const routeName = '/InsertNewMember';
  @override
  State<InsertNewMember> createState() => _InsertNewMemberState();
}



class _InsertNewMemberState extends State<InsertNewMember> {

  GlobalKey<FormState> insertMemberFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  late String _business_id;
  final TextEditingController _search = TextEditingController();
  final TextEditingController _memberFirstName = TextEditingController();
  final TextEditingController _memberLastName = TextEditingController();
  final TextEditingController _memberEmail = TextEditingController();
  //

  late List _listOfCommitteeData = [];

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

  late List _listOfRolesData = [];
  String? role="";

  Future getListRoles() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-roles/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-roles response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var rolesData = responseData['data'] ;
      // log.d(rolesData);
      setState((){
        _listOfRolesData = rolesData['roles'];
        // log.d(_listOfRolesData);
      });
    } else {
      log.d("get-list-roles response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  late List _listOfBoardsData = [];
  String? board="";
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
        // log.d(_listOfBoardsData);
      });
    } else {
      log.d("get-list-boards response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  List _committesListIds = [];
  List _selectedCommittees = [];

  @override
  void initState() {
    _selectedCommittees = [];
    _committesListIds = [];
    // TODO: implement initState
    super.initState();
    _memberFirstName.text = "";
    _memberLastName.text = "";
    _memberEmail.text = "";
    Future.delayed(Duration.zero, (){
      getListRoles();
      getListCommittees();
      getListBoards();
    });

  }

  @override
  Widget build(BuildContext context) {

    final _items = _listOfCommitteeData!
        .map((committee) => MultiSelectItem<dynamic>(committee, committee['committee_name']!))
        .toList();

    return Scaffold(
      appBar: Header(context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: insertMemberFormGlobalKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  const [
                    Text("#Add New Member",textScaleFactor: 1.5,style: TextStyle(fontWeight:FontWeight.bold,color: Colors.red,),),
                  ],
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 380,
                      child: StandTextFormField(
                        color: Colors.redAccent,
                        icon: Icons.people,
                        labelText: "First Name",
                        valid: (val){
                          if (val!.isNotEmpty ) {
                            return null;
                          } else {
                            return 'Enter a valid First Name';
                          }
                        },
                        controllerField: _memberFirstName,
                      ),
                    ),
                    Container(
                      width: 380,
                      child: StandTextFormField(
                        color: Colors.redAccent,
                        icon: Icons.people,
                        labelText: "Last Name",
                        valid: (val){
                          if (val!.isNotEmpty ) {
                            return null;
                          } else {
                            return 'Enter a valid Last Name';
                          }
                        },
                        controllerField: _memberLastName,
                      ),
                    ),
                    Container(
                      width: 380,
                      child: StandTextFormField(
                        color: Colors.redAccent,
                        icon: Icons.email,
                        labelText: "Email",
                        valid: (val){
                          if (isEmailValid(val!) && val.isNotEmpty ) {
                            return null;
                          } else {
                            return 'Enter a valid Email Name';
                          }
                        },
                        controllerField: _memberEmail,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 380,
                      constraints: BoxConstraints(minHeight: 30.0),
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius:  BorderRadius.circular(10.0),
                          color: Colors.white38,
                          boxShadow:  [
                            BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                          ]),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          isDense: true,
                          menuMaxHeight: 300,
                          style: Theme.of(context).textTheme.headline6,
                          hint: const Text("Given an Roles",style: TextStyle(color: Colors.white)),
                          dropdownColor: Colors.white60,
                          focusColor: Colors.redAccent[300],
                          // Initial Value
                          value: role,
                          icon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
                          // Array list of items
                          items:[
                            const DropdownMenuItem(
                              value: "",
                              child: Text("Select an Roles",style: TextStyle(color: Colors.white)),
                            ),
                            ..._listOfRolesData!.map((item){
                              return DropdownMenuItem(
                                value: item['id'].toString(),
                                child: Text(item['name'],style: const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ]
                          ,
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {
                            role = newValue!.toString();
                            setState(() {
                              role = newValue!;
                            });
                            print(role);
                          },

                        ),

                      ),
                    ),
                    Container(
                      width: 380,
                      constraints: BoxConstraints(minHeight: 30.0),
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius:  BorderRadius.circular(10.0),
                          color: Colors.white38,
                          boxShadow:  [
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
                          ]
                          ,
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {
                            board = newValue!.toString();
                            setState(() {
                              board = newValue!;
                            });
                            print(board);
                          },

                        ),

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Container(
                  constraints: BoxConstraints(minHeight: 30.0),
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius:  BorderRadius.circular(10.0),
                      color: Colors.white38,
                      boxShadow:  [
                        BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                      ]),
                  child: MultiSelectDialogField<dynamic>(
                    separateSelectedItems: true,
                    buttonIcon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
                    title: const Text("Committees List"),
                    buttonText: const Text("Select Multiple Committees",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
                    items: _items,
                    searchable: true,
                    validator: (values) {
                      if (values == null || values.isEmpty) {
                        return "Required";
                      }
                      List committees = values.map((committee) => committee['id']).toList();
                      if (committees.contains("Committees")) {
                        return "Committee are weird!";
                      }
                      return null;
                    },
                    onConfirm: (values) {
                      setState(() {
                        _selectedCommittees = values;
                         _committesListIds = _selectedCommittees.map((e) => e['id']).toList();
                        print(_committesListIds);
                        print(_selectedCommittees);
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (item) {
                        setState(() {
                          _selectedCommittees.remove(item);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      ElevatedButton.icon(
                        onPressed: () async {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          user = User.fromJson(json.decode(prefs.getString("user")!)) ;
                          setState((){
                            _business_id = user.businessId.toString();
                          });
                          if (insertMemberFormGlobalKey.currentState!.validate()) {
                            insertMemberFormGlobalKey.currentState!.save();

                            Map<String, dynamic> data = {
                              "member_first_name": _memberFirstName.text,"member_last_name": _memberLastName.text,
                              "member_email": _memberEmail.text,
                              "board_id": board!, "committee_id": _committesListIds!,"role": role!,
                              "business_id": _business_id
                            };
                            var response = await networkHandler.post1("/insert-new-member", data);
                            if (response.statusCode == 200 || response.statusCode == 201) {
                              setState((){
                                isLoading = true;
                              });
                              log.d("insert-new-member response statusCode == 200");
                              var responseData = json.decode(response.body);
                              var memberData = responseData['data'];
                              var member = Member.fromJson(memberData);
                              log.d(member);
                              Navigator.pop(context);

                              Flushbar(
                                title: "Create Member has been Successfully",
                                message: json.decode(response.body)['message'].toString(),
                                duration: Duration(seconds: 6),
                                backgroundColor: Colors.greenAccent,
                                titleColor: Colors.white,
                                messageColor: Colors.white,
                              ).show(context);
                              Navigator.pushReplacementNamed(context, MembersList.routeName);
                            } else {
                              setState((){
                                isLoading = false;
                              });
                              print(response.statusCode);
                              print(json.decode(response.body)['message']);
                              Flushbar(
                                title: "Create Member has been Faild",
                                message: json.decode(response.body)['message'].toString(),
                                duration: Duration(seconds: 6),
                                backgroundColor: Colors.redAccent,
                                titleColor: Colors.white,
                                messageColor: Colors.white,
                              ).show(context);
                            }
                          }
                        },
                        icon: Icon(Icons.add,size: 30,color: Colors.white,),
                        label: Text('Add Member',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, MembersList.routeName),
                        child: const Text('Cancel',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool isEmailValid(String val) {
    final RegExp regex =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    return regex.hasMatch(val);
  }

}
