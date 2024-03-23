import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../NetworkHandler.dart';
import '../../core/domains/app_uri.dart';
import '../../models/committee_model.dart';
import '../../models/user.dart';
import '../../providers/committee_provider.dart';
import '../../providers/meeting_page_provider.dart';
import '../../utility/pdf_api.dart';
import '../../utility/pdf_pragraph_committee_api.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/stand_text_form_field.dart';
import '../pdfTron/pdf_tron.dart';

class CommitteeList extends StatefulWidget {
  const CommitteeList({Key? key}) : super(key: key);
  static const routeName = '/CommitteeList';

  @override
  State<CommitteeList> createState() => _CommitteeListState();
}

class _CommitteeListState extends State<CommitteeList> {

  final insertCommitteeFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late String _business_id;

  TextEditingController _search = TextEditingController();
  TextEditingController boardStartDate = TextEditingController();
  TextEditingController endFiscalYear = TextEditingController();
  TextEditingController _commiteeName = TextEditingController();
  TextEditingController _boardName = TextEditingController();

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

  // Initial Selected Value
  String dropdownvalue = '51';
  // List of items in our dropdown menu
  var items = ['51','66','70'];

  // Initial Selected Value
  String yearSelected = '2023';
  // List of items in our dropdown menu
  var yeasList = ['2021','2022','2023','2024','2025','2026','2027','2028','2029','2030','2031','2032'];
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:5.0, horizontal: 10.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15.0),
                    color: Colors.red,
                    child: CustomText(text:'Reports',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 5.0,),
                Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15.0),
                    color: Colors.red,
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
                        value: yearSelected,
                        icon: const Icon(Icons.keyboard_arrow_down ,size: 20,color: Colors.white),
                        // Array list of items
                        items:[
                          const DropdownMenuItem(
                            value: "",
                            child: Text("Select an Year",style: TextStyle(color: Colors.black)),
                          ),
                          ...yeasList!.map((item){
                            return DropdownMenuItem(
                              value: item.toString(),
                              child: Text(item,style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                        ]
                        ,
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (String? newValue) {
                          yearSelected = newValue!.toString();
                          setState(() {
                            yearSelected = newValue!;
                          });
                          Map<String, dynamic> data = {"dateYearRequest": yearSelected!};
                          MeetingPageProvider providerGetMeetingByDateYear =  Provider.of<MeetingPageProvider>(context, listen: false);
                          Future.delayed(Duration.zero, () {
                            providerGetMeetingByDateYear.getListOfMeetingsCommittees(data);
                          });
                        },
                      ),
                    ),
                ),

              ],
            ),
            Center(
              child: Consumer<MeetingPageProvider>(
                  builder: (context,  provider, child){
                    if(provider.dataOfMeetings?.meetings == null){
                      provider.getListOfMeetingsCommittees(context);
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
                    return provider.dataOfMeetings!.meetings!.isEmpty ?
                    Center(child: CustomText(text:'no data found',fontWeight: FontWeight.bold,color: Colors.red,),) :
                      SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          showBottomBorder: true,
                          dividerThickness: 5.0,
                          columns:const [
                            DataColumn(
                                label: Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show Committee name"),

                            DataColumn(
                                label: Text("Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show Committee Date"),

                            DataColumn(
                                label: Text("File",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "File"),

                            DataColumn(
                                label: Text("Presented at",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "Presented at"),

                            DataColumn(
                                label: Text("Owner",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "Owner"),

                            DataColumn(
                                label: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show buttons for functionality members"),
                          ],
                          rows: provider!.dataOfMeetings!.meetings!.map((meeting) =>
                              DataRow(
                                  cells: [
                                    DataCell(Text(meeting!.meetingTitle!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                    DataCell(Text('${meeting!.meetingStart!}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                    DataCell(
                                      TextButton(
                                        onPressed: () async{
                                          var businessName = meeting!.committee!.business!.businessId!;
                                          String charterName = meeting!.meetingFile!;
                                          String url = "${AppUri.publicUploadCharters}/$businessName/$charterName";
                                          print(url);
                                          openPDF(context,url,charterName);
                                        },
                                        child: Text(meeting?.meetingFile ?? 'Circular',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),),
                                      ),

                                    ),
                                    DataCell(Text(meeting?.meetingBy ?? 'loading ...',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                    DataCell(Text(meeting?.user?.firstName ?? 'loading ...',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),

                                    DataCell(
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children:[
                                              ElevatedButton.icon(
                                                label: const Text('View',style: TextStyle(color: Colors.white),),
                                                icon: const Icon(Icons.remove_red_eye_outlined,color: Colors.white),
                                                onPressed: () {print('View');},
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: EdgeInsets.symmetric(horizontal: 10.0)
                                                ),
                                              ),
                                              const SizedBox(width: 5.0,),
                                              ElevatedButton.icon(
                                                label: const Text('Export',style: TextStyle(color: Colors.white),),
                                                icon: const Icon(Icons.import_export_outlined,color: Colors.white),
                                                onPressed: () {print('Export');},
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: EdgeInsets.symmetric(horizontal: 10.0)
                                                ),
                                              ),
                                              const SizedBox(width: 5.0,),
                                              ElevatedButton.icon(
                                                label: const Text('Sign',style: TextStyle(color: Colors.white),),
                                                icon: const Icon(Icons.checklist_outlined,color: Colors.white),
                                                onPressed: () {print('Sign');},
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
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
            ),
          ],
        ),
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
                  key: insertCommitteeFormGlobalKey,
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
                              constraints: BoxConstraints(minHeight: 30.0),
                              padding: EdgeInsets.all(7),
                              margin: const EdgeInsets.all(8.0),
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
                            if (insertCommitteeFormGlobalKey.currentState!.validate()) {
                              insertCommitteeFormGlobalKey.currentState!.save();
                              if (pickedfile != null) {
                                final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
                                setState(() {
                                  _fileBase64 = fileBase64;
                                });
                              }

                              Map<String, dynamic> data = {
                                "committee_name": _commiteeName.text,'charter_committee': _fileNameNew!,'fileSelf': _fileBase64!,
                                "board_id": _board!,"business_id": _business_id
                              };
                              CommitteeProvider providerCommittee =  Provider.of<CommitteeProvider>(context, listen: false);
                              Future.delayed(Duration.zero, () {
                                providerCommittee.insertCommittee(data);
                              });

                              if(providerCommittee.isBack == true){
                                Navigator.pop(context);
                                Flushbar(
                                  title: "Create Committee has been Successfully",
                                  message: "Create Committee has been Successfully",
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.greenAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              } else {
                                Flushbar(
                                  title: "Create Committee has been Faild",
                                  message: "Create Committee has been Faild",
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


  void openPDF(BuildContext context, String file,String fileName) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPageSyncfusionPackage(file: file, fileName: fileName,)),
  );
}
