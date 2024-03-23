import 'package:diligov/views/modules/evaluation_views/evaluation_home.dart';
import 'package:diligov/views/modules/evaluation_views/member_evaluation_details.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../models/member.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../../../models/user.dart';
import '../../../widgets/appBar.dart';
class EvaluationListViews extends StatefulWidget {
  const EvaluationListViews({Key? key}) : super(key: key);
  static const routeName = '/EvaluationListViews';

  @override
  State<EvaluationListViews> createState() => _EvaluationListViewsState();
}

class _EvaluationListViewsState extends State<EvaluationListViews> {
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
   bool isLoading  = false;

  late List dataOfMembers = [];
  Future getListMembers() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
      var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("get-list-members response statusCode == 200");
        var responseData = json.decode(response.body) ;
        var membersData = responseData['data'] ;
          setState((){
            dataOfMembers = membersData['members'];
            isLoading = true;
            log.d(dataOfMembers!.length);
          });
      } else {
        log.d("get-list-members response statusCode unknown");
        print(json.decode(response.body)['message']);
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, (){
      getListMembers();
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Column(
        mainAxisSize:MainAxisSize.min,
        children: [
          buildFullTopFilter(),
          dataOfMembers.isEmpty ? Center(
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
          ) : GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              crossAxisCount: 5,
            ),
            itemCount: dataOfMembers!.length, // <-- required
            itemBuilder: (BuildContext ctx, i)  {
                final Member  member = Member.fromJson(dataOfMembers![i]);
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>  MemberEvaluationDetails(member: member,))
                ),
                child: Container(
                  color: Colors.grey[300],
                  height: 50,
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 100,
                        child: Container(
                            width: 190.0,
                            height: 190.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: member.memberProfileImage == null ?
                                  AssetImage("assets/images/profile.jpg",) as ImageProvider :
                                    NetworkImage('https://diligov.com/public/profile_images/${member.businessId}/${member.memberProfileImage}')
                                )
                            )
                        )
                      ),
                      const SizedBox(height: 10.0,),
                      CustomText(text:'${member.memberFirstName}',fontSize: 20.0,fontWeight: FontWeight.bold,)
                    ],
                  ),
                ),
              );
            }
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
            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
            color: Colors.red,
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, EvaluationListViews.routeName);
              },
              child: CustomText(text:'Members View Result',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            )
        ),
        const SizedBox(width: 5.0,),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
            color: Colors.red,
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, EvaluationListViews.routeName);
              },
              child: CustomText(text:'Boards View Result',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            )
        ),
        const SizedBox(width: 5.0,),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
            color: Colors.red,
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, EvaluationHome.routeName);
              },
              child: CustomText(text:'Evaluation Home',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            )
        ),
      ],
    ),
  );


}
