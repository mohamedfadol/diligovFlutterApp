import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:diligov/providers/committee_provider.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../../NetworkHandler.dart';
import '../../../providers/member_page_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../utility/signature_perview.dart';
import '../../../widgets/stand_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../widgets/appBar.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
class MembersList extends StatefulWidget {
  const MembersList({Key? key}) : super(key: key);
  static const routeName = '/MembersList';
  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList>  with InputValidationMixin{
  GlobalKey<FormState> insertMemberFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();
  bool isLoading = false;
  NetworkHandler networkHandler = NetworkHandler();

  late SignatureController signController;
  Uint8List? signature;
  Uint8List? uploadSignature;

  late String _business_id;
  final TextEditingController _memberPassword = TextEditingController();
  final TextEditingController _memberFirstName = TextEditingController();
  final TextEditingController? _memberMiddelName = TextEditingController();
  final TextEditingController _memberLastName = TextEditingController();
  final TextEditingController _memberEmail = TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? _imageBase64 ;
  String? _imageName ;

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
        // print(_listOfCommitteeData);
      });
    } else {
      log.d("get-list-committees response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  late List _listOfPositionsData = [];
  String? position="";

  Future getListPositions() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-positions/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-positions response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var positionData = responseData['data'] ;
      // log.d(rolesData);
      setState((){
        _listOfPositionsData = positionData['positions'];
        // log.d(_listOfPositionsData);
      });
    } else {
      log.d("get-list-positions response statusCode unknown");
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
      signController = SignatureController(penColor: Colors.black,penStrokeWidth: 1,);
      _memberFirstName.text = "";
      _memberMiddelName?.text = "";
      _memberLastName.text = "";
      _memberEmail.text = "";
      _memberPassword.text = "";
    Future.delayed(Duration.zero, (){
      getListPositions();
      getListCommittees();
      getListBoards();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
      signController.dispose();
      _memberPassword.dispose();
      _memberFirstName.dispose();
      _memberMiddelName?.dispose();
      _memberLastName.dispose();
      _memberEmail.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Consumer<MemberPageProvider>(
              builder: (context,  provider, child){
                if(provider.dataOfMembers?.members == null){
                    provider.getListOfMember(context);
                    return Center(child: SpinKitThreeBounce(
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
                  return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,

                      child: DataTable(
                        showBottomBorder: true,
                        dividerThickness: 5.0,
                          columns:const [
                            DataColumn(
                                  label: Text("First Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                    tooltip: "show member first name"),

                            DataColumn(
                                  label: Text("Last Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                    tooltip: "show member last name"),
                            DataColumn(
                                  label: Text("E-mail",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                    tooltip: "show member email Id"),
                            DataColumn(
                                label: Text("Roles",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show member roles"),

                            DataColumn(
                                  label: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                    tooltip: "show buttons for functionality members"),
                          ],
                          rows: provider.dataOfMembers!.members!.map((meb) =>
                            DataRow(
                              cells: [
                                DataCell(Text(meb.memberFirstName!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                DataCell(Text(meb?.memberLastName ?? " ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                DataCell(Text(meb.memberEmail!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                DataCell(Text(meb.position!.positionName!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),

                                DataCell(
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children:[
                                          ElevatedButton.icon(
                                            label: const Text('Edit',style: TextStyle(color: Colors.white),),
                                            icon: const Icon(Icons.pending_sharp,color: Colors.white),
                                            onPressed: () {print('edit');},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding: EdgeInsets.symmetric(horizontal: 10.0)
                                            ),
                                          ),
                                          const SizedBox(width: 5.0,),
                                          ElevatedButton.icon(
                                            label: const Text('Delete',style: TextStyle(color: Colors.white),),
                                            icon: const Icon(Icons.restore_from_trash_outlined,color: Colors.white),
                                            onPressed: () {print('delete');},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: EdgeInsets.symmetric(horizontal: 10.0)
                                            ),
                                          ),
                                          const SizedBox(width: 5.0,),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              label: const Text('Permissions',style: TextStyle(color: Colors.white),),
                                              icon: const Icon(Icons.local_attraction_rounded,color: Colors.white),
                                              onPressed: () {print('permissions');},
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.indigo,
                                                  padding: EdgeInsets.symmetric(horizontal: 10.0)
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5.0,),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              label: const Text('Rest Password',style: TextStyle(color: Colors.white),),
                                              icon: const Icon(Icons.lock_open_outlined,color: Colors.white),
                                              onPressed: () {print('Rest Password');},
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black26,
                                                  padding: EdgeInsets.symmetric(horizontal: 10.0)
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                              ]
                            )
                          ).toList(),
                      ),
                    ),
                  );

              }
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 90,vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    label: const Text('Add User',style: TextStyle(color: Colors.red,fontSize: 20),),
                    icon: const Icon(Icons.add,size: 30.0,),
                    onPressed: () {openMemberCreateDialog();},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10.0)
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openMemberCreateDialog() => showDialog(
      context: context,
      builder:  (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: EdgeInsets.zero,
                title: const Text("Add New Member",style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(
                    key: insertMemberFormGlobalKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: Container(
                        width: 700,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Column(
                                    children: [
                                      imageProfile(),
                                      InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: ((builder) => bottomSheet()),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right:10),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:  BorderRadius.circular(20.0),
                                            ),
                                            child: Text('Change Picture',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                                          )
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Your Signature',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                      const SizedBox(height: 5.0,),
                                      Signature(
                                        controller: signController,
                                        backgroundColor: Colors.red,
                                        height: 100,
                                        width: 300,
                                      ),
                                      buildButton(context),
                                      // signature != null ? Image.memory(signature!) : Text('no signed')
                                    ],
                                  ),
                            ]
                            ),
                            SizedBox(height: 10.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Container(
                                  width: 325,
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
                                  width: 325,
                                  child: StandTextFormField(
                                    color: Colors.redAccent,
                                    icon: Icons.people,
                                    labelText: "Middel Name",
                                    valid: (val){
                                      if (val!.isNotEmpty ) {
                                        return null;
                                      } else {
                                        return 'Enter a valid Middel Name';
                                      }
                                    },
                                    controllerField: _memberMiddelName,
                                  ),
                                ),
                              ]
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 325,
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
                                  width: 325,
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
                            SizedBox(height: 10,),
                            Container(
                              child: StandTextFormField(
                                color: Colors.redAccent,
                                icon: Icons.lock_open,
                                labelText: "Password",
                                valid: (val){
                                  if (isPasswordValid(val!)  && val!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'Enter a valid Password';
                                  }
                                },
                                controllerField: _memberPassword,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 325,
                                  constraints: const BoxConstraints(minHeight: 15.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                                  decoration: BoxDecoration(
                                      borderRadius:  BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow:  const [
                                        BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                                      ]),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: true,
                                      menuMaxHeight: 100,
                                      style: Theme.of(context).textTheme.headline6,
                                      hint: const Text("Given an Position",style: TextStyle(color: Colors.black)),
                                      dropdownColor: Colors.white60,
                                      focusColor: Colors.redAccent[300],
                                      // Initial Value
                                      value: position,
                                      icon: const Icon(Icons.keyboard_arrow_down ,size: 20),
                                      // Array list of items
                                      items:[
                                        const DropdownMenuItem(
                                          value: "",
                                          child: Text("Select an Position",style: TextStyle(color: Colors.black)),
                                        ),
                                        ..._listOfPositionsData!.map((item){
                                          return DropdownMenuItem(
                                            value: item['id'].toString(),
                                            child: Text(item['position_name'],style: const TextStyle(color: Colors.black)),
                                          );
                                        }).toList(),
                                      ]
                                      ,
                                      // After selecting the desired option,it will
                                      // change button value to selected value
                                      onChanged: (String? newValue) {
                                        position = newValue!.toString();
                                        setState(() {
                                          position = newValue!;
                                        });
                                        print(position);
                                      },

                                    ),

                                  ),
                                ),
                                Container(
                                  width: 325,
                                  constraints: BoxConstraints(minHeight: 15.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                                  decoration: BoxDecoration(
                                      borderRadius:  BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow:  const [
                                        BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                                      ]),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: true,
                                      menuMaxHeight: 100,
                                      style: Theme.of(context).textTheme.headline6,
                                      hint: const Text("Select an Board",style: TextStyle(color: Colors.black)),
                                      dropdownColor: Colors.white60,
                                      focusColor: Colors.redAccent[300],
                                      // Initial Value
                                      value: board,
                                      icon: const Icon(Icons.keyboard_arrow_down ,size: 20),
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
                            SizedBox(height: 10,),
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
                                separateSelectedItems: true,
                                buttonIcon: const Icon(Icons.keyboard_arrow_down ,size: 20),
                                title: const Text("Committees List"),
                                buttonText: const Text("Select Multiple Committees",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold)),
                                items: _listOfCommitteeData!
                                    .map((committee) => MultiSelectItem<dynamic>(committee, committee['committee_name']!))
                                    .toList(),
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
                            SizedBox(height: 10,),
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
                                        if (_imageFile != null) {
                                          final  imageBase64 = base64.encode(File(_imageFile!.path).readAsBytesSync());
                                          String imageName = _imageFile!.path.split("/").last;
                                          setState(()  {
                                            _imageBase64 = imageBase64;
                                            _imageName = imageName;
                                          });

                                        }
                                        Map<String, dynamic> data = {
                                          "member_first_name": _memberFirstName.text,"member_last_name": _memberLastName.text,
                                          "member_email": _memberEmail.text,"member_password": _memberPassword.text,
                                          "board_id": board!, "committee_id": _committesListIds!,"position_id": position!,
                                          "member_middel_name": _memberMiddelName?.text,"business_id": _business_id,
                                          'member_profile_image': _imageName!, 'imageSelf': _imageBase64!,"uploadSignature": base64.encode(signature!)
                                        };

                                        MemberPageProvider providerMember =  Provider.of<MemberPageProvider>(context, listen: false);
                                        Future.delayed(Duration.zero, () {
                                          providerMember.insertMember(data);
                                        });
                                        if(providerMember.isBack == true){
                                          Navigator.pop(context);

                                          Flushbar(
                                            title: "Create Member has been Successfully",
                                            message: "Create Member has been Successfully",
                                            duration: Duration(seconds: 6),
                                            backgroundColor: Colors.greenAccent,
                                            titleColor: Colors.white,
                                            messageColor: Colors.white,
                                          ).show(context);
                                        }else{
                                          Flushbar(
                                            title: "Create Member has been Failed",
                                            message: "Create Member has been Failed",
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
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ]
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              );
            }
        );
      }
  );


  Widget buildButton(BuildContext context) => Container(
    color: Colors.black,
    width: 300,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildSave(context),
        buildClear()
      ],
    ),
  );

  buildSave(BuildContext context) => IconButton(
      onPressed: () async{
        if(signController.isNotEmpty){
          signature = await exportSignature();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignaturePerview(signature: signature!),
          ));
        }
      },
      icon: const Icon(Icons.save, color: Colors.green,)
  );

  buildClear() => IconButton(
      onPressed: (){ signController.clear();},
      icon: const Icon(Icons.clear, color: Colors.green,)
  );

  Future<Uint8List?> exportSignature() async{
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.blue[900]!,
      exportBackgroundColor: Colors.white,
      points: signController.points,
    );
    signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }



  Widget bottomSheet(){
    return Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal:20, vertical:20),
        child: Column(
            children:[
              Text('Choose an Photo',style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.camera);
                      },
                      icon: Icon(Icons.camera,size: 24.0,),
                      label: Text('Camera'), // <-- Text
                    ),
                    SizedBox(width:15),
                    ElevatedButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.gallery);
                      },
                      icon: Icon(Icons.image,size: 24.0,),
                      label: Text('Gallery'), // <-- Text
                    ),

                  ]
              )
            ]
        )
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.brown.shade800,
            radius: 70.0,
            backgroundImage: _imageFile == null ?
            AssetImage("assets/images/profile.jpg",) as ImageProvider : FileImage(File(_imageFile!.path)),
          ),
          Positioned(
              child: InkWell(
                  onTap: (){
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => bottomSheet()),
                    );
                  },
                  child: Icon(Icons.camera_alt,size: 40, color: Colors.teal,)
              )

          )
        ],
      ),
    );
  }

  Future<XFile?> takePhoto(ImageSource source) async{
    final XFile? image = await _picker.pickImage(source: source);
    setState(() { _imageFile = image ;   });
  }

}

mixin InputValidationMixin {
  bool isPasswordValid(String val) => val.length == 6;

  bool isEmailValid(String val) {
    final RegExp regex =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    return regex.hasMatch(val);
  }
}

