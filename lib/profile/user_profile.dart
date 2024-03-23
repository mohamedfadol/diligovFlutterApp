import 'package:diligov/colors.dart';
import 'package:diligov/profile/edit_user_profile.dart';
import 'package:flutter/material.dart';

import '../widgets/buttons.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  ScrollController _scrollController = ScrollController();

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Scaffold(
        backgroundColor: Colour().lightBackgroundColor,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    SystemButton("Devices", () {},Colour().buttonColor,Colors.black,30,20),
                    SystemButton("Log In", () {},Colour().buttonColor,Colors.black,30,20),
                    SystemButton("Accessed Content", () {},Colour().buttonColor,Colors.black,30,20),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Material(
                        elevation: 10,
                        color: Colour().buttonColor,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: EdgeInsets.all(30),
                          width: 250,
                          height: 270,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colour().buttonColor,
                          ),
                          child: Image.asset("images/default_user_image.png"),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        DisplayInfoContainer("AbdullahMQ1998", true,Colour().buttonColor),
                        DisplayInfoContainer("Abdullah", false,Colour().buttonColor),
                        DisplayInfoContainer("Alqahtani", false,Colour().buttonColor),
                      ],
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, bottom: 20),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          DisplayInfoContainer("Audit Committee", true,Colour().buttonColor),
                          DisplayInfoContainer("Board of Directors", false,Colour().buttonColor),
                          DisplayInfoContainer("NRC Committee", false,Colour().buttonColor),
                        ],
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SystemButton("Edit Profile", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditUserProfile()));
                        },Colors.red,Colors.white,30,20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 1,
              top: 105,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 20,
                    radius: Radius.circular(30),
                    controller: _scrollController,
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              padding: EdgeInsets.only(top:30 , left: 50,right: 50),
                              width: 400,
                              height: 500,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Necessary ye contented newspaper zealously breakfast he prevailed. Melancholy middletons yet understood decisively boy law she. Answer him easily are its barton little. Oh no though mother be things simple itself. Dashwood horrible he strictly on as. Home fine in so am good body this hope.Six started far placing saw respect females old. Civilly why how end viewing attempt related enquire visitor. Man particular insensible celebrated conviction stimulated principles day. Sure fail or in said west. Right my front it wound cause fully am sorry if. She jointure goodness interest debating did outweigh. Is time from them full my gone in went. Of no introduced am literature excellence mr stimulated contrasted increasing. Age sold some full like rich new. Amounted repeated as believed in confined juvenile",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ));
                        }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayInfoContainer extends StatelessWidget {
  DisplayInfoContainer(this.text, this.firstItem,this.color);
  final String text;
  final bool firstItem;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: firstItem ? EdgeInsets.zero : EdgeInsets.only(top: 18),
      child: Material(
        elevation: 10,
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}


