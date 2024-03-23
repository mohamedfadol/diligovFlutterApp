import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:diligov/views/modules/evaluation_views/evaluation_home.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/user.dart';
import '../../../providers/evaluation_page_provider.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custome_text.dart';
class MemberPeerAssessment extends StatefulWidget {
  const MemberPeerAssessment({Key? key}) : super(key: key);
  static const routeName = '/MemberPeerAssessment';

  @override
  State<MemberPeerAssessment> createState() => _MemberPeerAssessmentState();
}

class _MemberPeerAssessmentState extends State<MemberPeerAssessment> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _criteriaText = [];
  final List<TextEditingController> _criteriaCategory = [];
  User user = User();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  late String _business_id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addField();
    });

  }

  _addField(){
    setState(() {
      _criteriaText.add(TextEditingController());
      _criteriaCategory.add(TextEditingController());
    });
  }

  _removeItem(i){
    setState(() {
      _criteriaText.removeAt(i);
      _criteriaCategory.removeAt(i);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 150),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              buildHeaderButtons(),
              const SizedBox(height: 10,),
              for(int i = 0; i < _criteriaText.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(5.0),
                        color: Colors.white10,
                        child: Text('${i+1}')
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 5,),
                          Flexible(
                            child: TextFormField(
                              controller: _criteriaCategory[i],
                              validator: (val) => val != null && val.isEmpty ? 'please enter criteria Category' : null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Criteria Category',
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0,),
                          Flexible(
                            child: TextFormField(
                              controller: _criteriaText[i],
                              validator: (val) => val != null && val.isEmpty ? 'please enter criteria Text' : null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Criteria Text',
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0,),
                          const Divider(color: Colors.red,thickness: 2,),
                        ],
                      ),
                    ),
                    buildRemoveAtButton(i),
                  ],
                ),

              buildEditingActions()
            ],
          ),
        ),
      ),
    );
  }

Widget buildHeaderButtons() => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 0.0),
        child: TextButton(
          onPressed: (){
            Navigator.pushReplacementNamed(context, EvaluationHome.routeName);
          },
          child: CustomText(text:'Back',color: Colors.white,fontWeight: FontWeight.bold,),
        )
    ),
    Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 5.0),
        child: buildAddButton()
    ),
  ],
);

Widget buildEditingActions() =>
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: const Icon(Icons.done),
      label: const Text('Save'),
    )
  ;

  Future saveForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> criteriaList =[];
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      if(_criteriaText.isNotEmpty){

        for(int i =0; i < _criteriaText.length; i++){
          criteriaList.add({
            "criteria_text": _criteriaText[i].text,
            "criteria_category": _criteriaCategory[i].text,
            "created_by": user.userId,
            "business_id": user.businessId
          });
        }
      }
      Map<String, dynamic> data = {
        "listOfCriteria": criteriaList,
      };
      final provider = Provider.of<EvaluationPageProvider>(context,listen: false);
      Future.delayed(Duration.zero, () {
        provider.insertNewCriteria(data);
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
        Navigator.pushReplacementNamed(context, EvaluationHome.routeName);
        });
      }else{
        Flushbar(
          title: "Create Criteria has been Faild",
          message: "Create Criteria has been Faild",
          duration: Duration(seconds: 6),
          backgroundColor: Colors.redAccent,
          titleColor: Colors.white,
          messageColor: Colors.white,
        ).show(context);
      }

    }
  }


  Widget buildAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: (){
          _addField();
        },
        child: const Icon(Icons.add,size:35,color: Colors.white,),
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

