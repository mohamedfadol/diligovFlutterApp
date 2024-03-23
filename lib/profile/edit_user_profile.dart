import 'dart:io';

import 'package:diligov/colors.dart';
import 'package:diligov/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditUserProfile extends StatefulWidget {
  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  String picturePath ="";
  bool userHasPic = false;
  File? pictureFile;
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {




    return Scaffold(
      backgroundColor: Colour().lightBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                    Container(
                      height: 220,
                      width: 220,
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        elevation: 10,
                        child: Center(
                            child: userHasPic ? Image.file(pictureFile!) :Text(
                              "Your Picture",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: SystemButton("Edit picture", () async {
                        final ImagePicker _picker = ImagePicker();
                        final XFile? photo =
                        await _picker.pickImage(source: ImageSource.gallery);

                        if (photo == null) {
                          return;
                        }
                        setState(() {
                          picturePath = photo.path;
                          pictureFile = File.fromUri(Uri(path: photo.path));
                          userHasPic = true;
                        });
                      }, Colors.red, Colors.white, 8, 0),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                       children: [
                         EditUserInfoContainer("Account","First Name","Last Name" , "Title"),
                         EditUserInfoContainer("Email","Current Password","New Password" , "Confirm Password"),
                       ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Material(
                              color: Colors.white,
                              elevation: 10,
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 500,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text("Biography:",style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),),
                                        ),
                                        Spacer(),
                                        IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      height: 100,
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
                                                  padding: EdgeInsets.only(left: 50,right: 50),
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
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            child: Material(
                              elevation: 10,
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: EdgeInsets.only(left: 20,top: 30,bottom: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding:EdgeInsets.only(bottom: 40),
                                      child: Text("ID Expiry Date:",style: TextStyle(
                                        fontSize: 25,
                                      ),),
                                    ),
                                    Text("Passport Expiry Date:",style: TextStyle(
                                      fontSize: 25
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),


              ],
            ),

          ],
        ),
      ),
    );
  }
}

class EditUserInfoContainer extends StatelessWidget {

  EditUserInfoContainer(this.firstText,this.secondText,this.thirdText,this.fourthText);

  final String firstText;
  final String secondText;
  final String thirdText;
  final String fourthText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Material(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                        height: 20,
                        child: IconButton(onPressed: (){}, icon: Icon(Icons.edit))
                    ),
                  ],
                ),
                editProfileTextWidget(firstText),
                editProfileTextWidget(secondText),
                editProfileTextWidget(thirdText),
                editProfileTextWidget(fourthText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class editProfileTextWidget extends StatelessWidget {
  editProfileTextWidget(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$text:",style: TextStyle(
            fontSize: 20,
          ),)
        ],
      ),
    );
  }
}
