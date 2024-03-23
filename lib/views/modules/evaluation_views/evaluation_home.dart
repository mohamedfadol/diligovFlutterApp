import 'dart:convert';

import 'package:diligov/views/modules/evaluation_views/evaluation_list_views.dart';
import 'package:diligov/views/modules/evaluation_views/member_peer_assessment.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../../../models/user.dart';
import '../../../providers/evaluation_page_provider.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custome_text.dart';
class EvaluationHome extends StatefulWidget {
  const EvaluationHome({Key? key}) : super(key: key);
  static const routeName = '/EvaluationHome';

  @override
  State<EvaluationHome> createState() => _EvaluationHomeState();
}

class _EvaluationHomeState extends State<EvaluationHome> {

  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  // Initial Selected Value
  String yearSelected = '2023';
  // List of items in our dropdown menu
  var yeasList = ['2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030','2031','2032'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: ListView(
        children: [
          buildFullTopFilter(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 500,
                        width: 400,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey,width: 5.0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: GestureDetector(
                          onTap: (){},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIcon(icon:Icons.add,color: Colors.red,size: 100,),
                              const SizedBox(height: 15.0,),
                              CustomText(text:'Board Effectiveness',color: Colors.black,fontWeight: FontWeight.bold,)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 50.0,),
                      Container(
                        height: 500,
                        width: 400,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey,width: 5.0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, MemberPeerAssessment.routeName);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIcon(icon:Icons.add,color: Colors.red,size: 100,),
                              const SizedBox(height: 15.0,),
                              CustomText(text:'Members Assessment',color: Colors.black,fontWeight: FontWeight.bold,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget  buildFullTopFilter() => Padding(
    padding: const EdgeInsets.only(top: 3.0,left: 0.0,right: 8.0,bottom: 8.0),
    child: Row(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15.0),
            color: Colors.red,
            child: CustomText(text:'Evaluations',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)
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
              onChanged: (String? newValue) async{
                yearSelected = newValue!.toString();
                setState(() {
                  yearSelected = newValue!;
                });
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
                print(user.businessId);
                Map<String, dynamic> data = {"dateYearRequest": yearSelected!,"business_id":user.businessId};
                EvaluationPageProvider providerGetResolutionsByDateYear =  Provider.of<EvaluationPageProvider>(context, listen: false);
                Future.delayed(Duration.zero, () {
                  providerGetResolutionsByDateYear.getListOfEvaluationsMember(data);
                });
              },
            ),
          ),
        ),

      ],
    ),
  );

}
