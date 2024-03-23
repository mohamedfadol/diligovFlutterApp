import 'package:diligov/views/user/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/user.dart';
import '../../providers/authentications/user_provider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/lable_and_data.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({Key? key}) : super(key: key);
  static const routeName = '/profileUser';

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  bool loading = true;
  User profileUserData = User();
  Future getUserProfile() async {
    var user = await Provider.of<UserProfilePageProvider>(context, listen: false).user;
    setState(() {
      profileUserData = user;
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loading
          ? Center(
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
            )
          : Padding(
              padding: EdgeInsets.only(left: 50, right: 80),
              child: ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  CustomText(
                      text: "Admin Profile",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LebleAndData(dataName: profileUserData.firstName.toString(),size: 10 ,lebaleName: 'First Name'),
                        LebleAndData(dataName: profileUserData.lastName.toString(),size: 10 ,lebaleName: 'Last Name'),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                backgroundColor: Colors.brown.shade800,
                                radius: 50,
                                child: Image.network('https://diligov.com/public/profile_images/${profileUserData.profileImage}')
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 700),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LebleAndData(dataName: profileUserData.userType.toString(),size: 6 ,lebaleName: 'Title Name'),
                        LebleAndData(dataName: profileUserData.email.toString(),size: 6 ,lebaleName: 'E-mail Address'),
                        LebleAndData(dataName: profileUserData.mobile.toString(),size: 10 ,lebaleName: 'Phone Number'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          color: Colors.grey[200],
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Card(
                            elevation: 0.0,
                            child: CustomText(
                              text: profileUserData.biography.toString() ?? '',
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            color: Colors.grey,
                            margin: EdgeInsets.symmetric(vertical: 20),
                            padding: EdgeInsets.all(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  EditProfile.routeName,
                                  arguments: {
                                    'id': profileUserData.userId,
                                  },
                                );
                              },
                              child: CustomText(
                                  text: 'Edit Profile Informations',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
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
}
