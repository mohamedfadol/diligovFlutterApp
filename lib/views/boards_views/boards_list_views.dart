import 'dart:convert';
import 'dart:io';
import 'package:diligov/providers/meeting_page_provider.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../NetworkHandler.dart';
import '../../models/user.dart';
import '../../providers/board_page_provider.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/date_format_text_form_field.dart';
import '../../widgets/stand_text_form_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BoardsListViews extends StatefulWidget {
  const BoardsListViews({Key? key}) : super(key: key);
  static const routeName = '/BoardsCharter';
  @override
  State<BoardsListViews> createState() => _BoardsListViewsState();
}

class _BoardsListViewsState extends State<BoardsListViews> {

  final insertBoardFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late String _business_id;

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

  TextEditingController boardStartDate = TextEditingController();
  TextEditingController endFiscalYear = TextEditingController();
  TextEditingController _boardName = TextEditingController();


  // Initial Selected Value
  String dropdownvalue = '51';
  // List of items in our dropdown menu
  var items = ['51','66','70'];

  // Initial Selected Value
  String dropdownYearSelectvalue = '51';
  // List of items in our dropdown menu
  var years = ['3','4'];

  // Initial Selected Value
  String yearSelected = '2023';
  // List of items in our dropdown menu
  var yeasList = ['2021','2022','2023','2024','2025','2026','2027','2028','2029','2030','2031','2032'];

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
                      hint: const Text("Select an Year",style: TextStyle(color: Colors.white)),
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
                          providerGetMeetingByDateYear.getListOfMeetingsBoards(data);
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
                      provider.getListOfMeetingsBoards(context);
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
                    return  provider.dataOfMeetings!.meetings!.isEmpty ?
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white,width: 1.0)
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Center(child: CustomText(text:'No Data Found ...',fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.red,),)
                    ) :
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          showBottomBorder: true,
                          dividerThickness: 5.0,
                          columns:const [
                            DataColumn(
                                label: Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show Board name"),

                            DataColumn(
                                label: Text("Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                tooltip: "show Board Date"),

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
                                          var businessName = meeting!.board!.business!.businessId!;
                                          String charterName = meeting!.meetingFile!;
                                          String url = "https://diligov.com/public/charters/$businessName/$charterName";
                                          print(url);
                                          // openPDF(context,url,charterName);
                                        },
                                        child: Text(meeting?.meetingFile ?? 'Circular',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),),
                                      ),

                                    ),
                                    DataCell(Text(meeting?.meetingBy ?? 'loading ..',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                    DataCell(Text(meeting?.user?.firstName ?? 'loading ..',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
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
                              onTap: (){ontapGetDate(boardStartDate);},
                              icon: Icons.calendar_today,color: Colors.redAccent,
                            ),
                            const SizedBox(height:15),
                            const Text("Set Quorum etc: ( 51% - 66% - 70% ) this decides resolution approval",
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(height:10),
                            DropdownButton(
                              hint: Text("Set Quorum etc: ( 51% - 66% - 70% ) this decides resolution approval",
                                  style: TextStyle(color: Colors.white)),
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
                              dateinput: endFiscalYear,  labelText: "Set Financial Year End",
                              onTap: (){ ontapGetDate(endFiscalYear);},
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
                                  child: Text('Upload Charter',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
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

                              Map<String, dynamic> data = {
                                "term": boardStartDate.text,
                                "quorum": dropdownvalue,
                                "fiscal_year": endFiscalYear.text,
                                "board_name": _boardName.text,
                                "charter_board": _fileNameNew!,
                                "fileSelf": _fileBase64!,
                                "business_id": _business_id
                              };
                              BoardPageProvider providerBoard =  Provider.of<BoardPageProvider>(context, listen: false);
                              Future.delayed(Duration.zero, () {
                                providerBoard.insertBoard(data);
                              });
                              if(providerBoard.isBack == true){
                                Navigator.pop(context);

                                Flushbar(
                                  title: "Create Board has been Successfully",
                                  message: "Create Board has been Successfully",
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.greenAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              }else{
                                Flushbar(
                                  title: "Create Board has been Faild",
                                  message: "Create Board has been Faild",
                                  duration: Duration(seconds: 6),
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


  void ontapGetDate  (TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    if(pickedDate != null ){
      print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(pickedDate);
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
 

  // void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
  //   MaterialPageRoute(builder: (context) => PDFViewerPageAsyncfusion(file: file,fileName: fileName,)),
  // );


}
