import 'dart:convert';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/criteria_model.dart';
import '../../../models/member.dart';
import '../../../models/member_criteria.dart';
import '../../../models/user.dart';
import '../../../providers/evaluation_page_provider.dart';
import '../../../widgets/custome_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'evaluation_list_views.dart';

class MemberEvaluationDetails extends StatefulWidget {
  final Member member;
  const MemberEvaluationDetails({Key? key, required this.member})
      : super(key: key);

  @override
  State<MemberEvaluationDetails> createState() =>
      _MemberEvaluationDetailsState();
}

class _MemberEvaluationDetailsState extends State<MemberEvaluationDetails> {

  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  bool isLoading = false;
  bool isShow = false;
  bool isSelectedRow = true;
  // Initial Selected Value
  String yearSelected = '2023';
  bool isPressed = false;
  String msg ='index';
  // List of items in our dropdown menu
  var yeasList = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
    '2032'
  ];

  late List dataOfCriterias = [];
  Map<String,int?> rateMap = {} ;
      Future getListCriteria() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final String business_id = user.businessId.toString();
    var response =
        await networkHandler.get('/get-list-criterias-by-business-id/$business_id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-criterias response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      setState(() {
        dataOfCriterias = membersData['criterias'];
        isLoading = true;
        log.d(dataOfCriterias!.length);
        for(var item in dataOfCriterias){
          final  criteria = Criteria.fromJson(item);
          rateMap[criteria.criteriaId.toString()]=null;
        }
      });
    } else {
      log.d("get-list-criterias response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    Future.delayed(Duration.zero, () {
      getListCriteria();
    });
  }
  double? total = 0;
  List<int> degrees = [];
  List<MemberCriteria> criteriaDegreeList =[];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          backgroundColor: Colors.red,
        ),
        body: SafeArea(
          child: Column(
              mainAxisSize:MainAxisSize.min,
            children: [
              buildFullTopFilter(),
              buildFullNameOfMember(),
              Form(
                key: _formKey,
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0,horizontal: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: dataOfCriterias.isEmpty ? Center(
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
                            ) : ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: dataOfCriterias!.length,
                              itemBuilder: (BuildContext cont, int i) {
                                final Criteria criteria = Criteria.fromJson(dataOfCriterias![i]);
                                return SingleChildScrollView(
                                  child: IntrinsicHeight(
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                       children: <Widget>[
                                                         GestureDetector(
                                                           onTap: (){
                                                             setState(() {
                                                               isShow = !isShow;
                                                             });
                                                           },
                                                           child: CustomText(
                                                             text: '${criteria.criteriaCategory}',
                                                             fontSize: 20,
                                                             color: Colors.black,
                                                             fontWeight: FontWeight.bold,
                                                           ),
                                                         ),
                                                         const SizedBox(width: 300.0,),
                                                         Visibility(
                                                           visible: rateMap[criteria.criteriaId.toString()]==null|| rateMap[criteria.criteriaId.toString()]==0,
                                                           child: TextButton(
                                                               onPressed: (){
                                                                 setState(() {
                                                                  rateMap[criteria.criteriaId.toString()]=0;
                                                                   criteriaDegreeList.add(
                                                                       MemberCriteria(index: i,
                                                                                       criteriaId: criteria.criteriaId,
                                                                                       criteriaDegree: 0,
                                                                                       businessId: criteria.businessId
                                                                                       )
                                                                   );
                                                                 });
                                                               },
                                                               child: buildDegreeContainer(Colors.white,Colors.grey,'0')
                                                           ),
                                                         ),
                                                         Visibility(
                                                           visible: rateMap[criteria.criteriaId.toString()]==null|| rateMap[criteria.criteriaId.toString()]==25,
                                                           child: TextButton(
                                                               onPressed: (){
                                                                 setState(() {
                                                                   rateMap[criteria.criteriaId.toString()]=25;
                                                                   print("index Button  $isPressed");
                                                                   criteriaDegreeList.add(
                                                                       MemberCriteria(index: i,
                                                                                       criteriaId: criteria.criteriaId,
                                                                                       criteriaDegree: 25,
                                                                                       businessId: criteria.businessId
                                                                       )
                                                                   );
                                                                 });
                                                               },
                                                               child: buildDegreeContainer(Colors.white,Colors.black,'25')
                                                           ),
                                                         ),
                                                         Visibility(
                                                           visible: rateMap[criteria.criteriaId.toString()]==null|| rateMap[criteria.criteriaId.toString()]==50,
                                                           child: TextButton(
                                                               onPressed: (){
                                                                 setState(() {
                                                                   rateMap[criteria.criteriaId.toString()]=50;
                                                                   criteriaDegreeList.add(
                                                                       MemberCriteria(index: i,
                                                                           criteriaId: criteria.criteriaId,
                                                                           criteriaDegree: 50,
                                                                           businessId: criteria.businessId
                                                                       )
                                                                   );

                                                                 });

                                                               },
                                                               child: buildDegreeContainer(Colors.white,Colors.yellow,'50')
                                                           ),
                                                         ),
                                                         Visibility(
                                                           visible: rateMap[criteria.criteriaId.toString()]==null|| rateMap[criteria.criteriaId.toString()]==75,
                                                           child: TextButton(
                                                             onPressed: (){
                                                               print(i);
                                                               setState(() {
                                                                 rateMap[criteria.criteriaId.toString()]=75;
                                                                 criteriaDegreeList.add(
                                                                     MemberCriteria(index: i,
                                                                         criteriaId: criteria.criteriaId,
                                                                         criteriaDegree: 75,
                                                                         businessId: criteria.businessId
                                                                     )
                                                                 );

                                                               });
                                                             },
                                                             child: buildDegreeContainer(Colors.white,Colors.green,'75'),
                                                           ),
                                                         ),
                                                         Visibility(
                                                           visible: rateMap[criteria.criteriaId.toString()]==null|| rateMap[criteria.criteriaId.toString()]==100,
                                                           child: TextButton(
                                                             onPressed: (){
                                                               setState(() {
                                                                 rateMap[criteria.criteriaId.toString()]=100;
                                                                 criteriaDegreeList.add(
                                                                     MemberCriteria(index: i,
                                                                         criteriaId: criteria.criteriaId,
                                                                         criteriaDegree: 100,
                                                                         businessId: criteria.businessId
                                                                     )
                                                                 );

                                                               });
                                                             },
                                                             child: buildDegreeContainer(Colors.white,Colors.red,'100'),
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                    const SizedBox(height: 5.0,),
                                                    Visibility(
                                                      visible: isShow ? true : false,
                                                      child: CustomText(
                                                        text: criteria.criteriaText!,
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                buildHorizontalDivider(),
                                              ],
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            width: 15.0,
                                            thickness: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(
                          width: 330,
                          child: buildRightSideDetails(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );


  Widget buildRowDetails(Criteria criteria,int i) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(
        child: buildLeftSideDetails(criteria,i),
      ),
      const VerticalDivider(
        color: Colors.grey,
        width: 15.0,
        thickness: 5,
      ),
    ],
  );

  Widget buildLeftSideDetails(Criteria criteria,int i) => Column(
        children: [
          buildLeftDetails(criteria,i),
          buildHorizontalDivider(),
        ],
      );

  Widget buildLeftDetails(Criteria criteria,int i) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  setState(() {
                    isShow = !isShow;
                  });
                },
                child: CustomText(
                  text: '${criteria.criteriaCategory}',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 300.0,),
              TextButton(
                  onPressed: (){
                    setState(() {
                      criteriaDegreeList.add(MemberCriteria(index: i,criteriaId: criteria.criteriaId,electedBy: widget.member.memberId,criteriaDegree: 0));
                      isSelectedRow = !isSelectedRow;

                    });
                  },
                  child: buildDegreeContainer(Colors.white,Colors.grey,'0')
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      degrees.add(25);
                      criteriaDegreeList.add(
                          MemberCriteria(index: i,criteriaId: criteria.criteriaId,electedBy: widget.member.memberId,criteriaDegree: 25));
                      print(criteriaDegreeList);
                    });
                  },
                  child: buildDegreeContainer(Colors.white,Colors.black,'25')
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      degrees.add(50);
                      criteriaDegreeList.add(
                          MemberCriteria(index: i,criteriaId: criteria.criteriaId,electedBy: widget.member.memberId,criteriaDegree: 50));
                      print(criteriaDegreeList);
                    });

                  },
                  child: buildDegreeContainer(Colors.white,Colors.yellow,'50')
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      degrees.add(75);
                      criteriaDegreeList.add(
                          MemberCriteria(index: i,criteriaId: criteria.criteriaId,electedBy: widget.member.memberId,criteriaDegree: 75));
                      print(criteriaDegreeList);
                    });
                  },
                  child: buildDegreeContainer(Colors.white,Colors.green,'75'),
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      degrees.add(100);
                      criteriaDegreeList.add(
                          MemberCriteria(index: i,criteriaId: criteria.criteriaId,electedBy: widget.member.memberId,criteriaDegree: 100));
                      print(criteriaDegreeList);
                    });
                  },
                  child: buildDegreeContainer(Colors.white,Colors.red,'100'),
              ),
            ],
          ),
      const SizedBox(height: 5.0,),
      Visibility(
        visible: isShow ? true : false,
        child: CustomText(
          text: criteria.criteriaText!,
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget buildHorizontalDivider() => const Divider(
        color: Colors.grey,
        thickness: 3,
      );

  Widget buildRightSideDetails() =>  Column(
   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
   crossAxisAlignment: CrossAxisAlignment.center,
   children: [
     Row(
       mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         CustomText(
           text: 'OverAll',
           fontSize: 20,
           color: Colors.grey,
           fontWeight: FontWeight.bold,
         ),
         const SizedBox(width: 30.0,),
          buildDegreeContainer(Colors.white,Colors.black,'6'),
       ],
     ),
     const Divider(
       thickness: 3,
       color: Colors.grey,
     ),
     Padding(
       padding: const EdgeInsets.only(top:40.0),
       child: CircleAvatar(
           backgroundColor: Colors.red,
           radius: 100,
           child: Container(
             width: 190.0,
               height: 190.0,
               decoration: const BoxDecoration(
                   shape: BoxShape.circle,
                    color: Colors.white,
               ),
             child: Center(
                 child: CustomText(text:'$total %',color: Colors.red,fontWeight: FontWeight.bold,fontSize: 40.0,)
             )
           )
       ),
     ),
     const SizedBox(height: 40.0,),
     Container(
       padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0),
       color: Colors.red,
       child: TextButton(
           onPressed: saveForm,
           child: CustomText(text:'Save & Continue',fontSize: 25.0,fontWeight: FontWeight.bold,color: Colors.white,)
       ),
     )
   ],
 );


  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    final isValid = _formKey.currentState!.validate();
    int? result = criteriaDegreeList.map((item) => item.criteriaDegree).reduce((value, current) => value! + current!);
    double finalTotal = result! /  criteriaDegreeList.length;
    setState(() { total = double.parse((finalTotal).toStringAsFixed(2)); });
    List<Map<String, dynamic>> criteriaList =[];
    // print(criteriaDegreeList.length);
    // print(result);
    // print(finalTotal);
    var removedDuplicatedData = criteriaDegreeList.toSet().toList();
    // print(removedDuplicatedData);
      if(criteriaDegreeList.isNotEmpty && criteriaDegreeList.length == removedDuplicatedData.length){
        for(int i =0; i < removedDuplicatedData.length; i++){
          criteriaList.add({
            "criteria_degree": removedDuplicatedData[i].criteriaDegree,
            "criteria_id": removedDuplicatedData[i].criteriaId,
            "elected_by": 51,//user.userId here should use member id authenticated,
            "member_id": widget.member.memberId,
            "business_id": removedDuplicatedData[i].businessId,
          });
        }
        Map<String, dynamic> data = {"listOfCriteriaEvaluations": criteriaList,"member_id": widget.member.memberId};
        final provider = Provider.of<EvaluationPageProvider>(context,listen: false);
        Future.delayed(Duration.zero, () {
          provider.insertNewEvaluationsMember(data);
        });
        if(provider.isBack == true){
          Flushbar(
            title: "Create Criteria has been Successfully",
            message: "Create Criteria has been Successfully",
            duration: Duration(seconds: 6),
            backgroundColor: Colors.greenAccent,
            titleColor: Colors.white,
            messageColor: Colors.white,
          ).show(context);
          Future.delayed(Duration(seconds: 10), () {
            Navigator.pushReplacementNamed(context, EvaluationListViews.routeName);
          });
        }else{
          Flushbar(
            title: "Create Criteria has been Failed",
            message: "please Click On All Values",
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.redAccent,
            titleColor: Colors.white,
            messageColor: Colors.white,
          ).show(context);
        }
      }else{
        Flushbar(
          title: "Create Criteria has been Failed",
          message: "please Click On All Values",
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.redAccent,
          titleColor: Colors.white,
          messageColor: Colors.white,
        ).show(context);
      }



  }


  Widget buildFullTopFilter() => Padding(
    padding:
    const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
    child: Row(
      children: [
        Container(
            padding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            color: Colors.red,
            child: CustomText(
                text: 'Evaluations',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          width: 140,
          padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          color: Colors.red,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.headline6,
              hint: const Text("Select an Year",
                  style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.white60,
              focusColor: Colors.redAccent[300],
              // Initial Value
              value: yearSelected,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Colors.white),
              // Array list of items
              items: [
                const DropdownMenuItem(
                  value: "",
                  child: Text("Select an Year",
                      style: TextStyle(color: Colors.black)),
                ),
                ...yeasList!.map((item) {
                  return DropdownMenuItem(
                    value: item.toString(),
                    child: Text(item,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ],
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) async {
                yearSelected = newValue!.toString();
                setState(() {
                  yearSelected = newValue!;
                });
                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                user = User.fromJson(json.decode(prefs.getString("user")!));
                print(user.businessId);
                Map<String, dynamic> data = {
                  "dateYearRequest": yearSelected!,
                  "business_id": user.businessId
                };
                EvaluationPageProvider providerGetResolutionsByDateYear =
                Provider.of<EvaluationPageProvider>(context,
                    listen: false);
                Future.delayed(Duration.zero, () {
                  providerGetResolutionsByDateYear
                      .getListOfEvaluationsMember(data);
                });
              },
            ),
          ),
        ),
      ],
    ),
  );

  Widget buildFullNameOfMember() => Row(
    children: [
      Container(
          margin: const EdgeInsets.only(left: 10.0, top: 10.0),
          padding: const EdgeInsets.all(10.0),
          color: Colors.grey,
          child: CustomText(
            text: "${widget!.member!.memberFirstName!}  "
                "${widget!.member?.memberMiddelName}  "
                "${widget!.member?.memberLastName}",
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    ],
  );

  Widget buildDegreeContainer(Color? textColor,Color? bgContainerColor, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 3.0),
      width: 60,
      decoration: BoxDecoration(
        color: bgContainerColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
          child: CustomText(
            text: text,
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.bold,
          )));


}
