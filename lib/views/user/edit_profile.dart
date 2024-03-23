import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:diligov/views/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../providers/authentications/user_provider.dart';
import '../../utility/signature_perview.dart';
import 'package:signature/signature.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/edit_form_text_field.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);
  static const routeName = '/editProfile';
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late SignatureController signController;
  Uint8List? signature;
  Uint8List? uploadSignature;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final editProfileFormGlobalKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _userType = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _biography = TextEditingController();

  @override
  void initState() {
    super.initState();
    signController = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 1,
    );
  }

  @override
  void dispose() {
    signController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final id = arguments['id'];
    String? _imageBase64;
    String? _imageName;
    print(id);
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Form(
        key: editProfileFormGlobalKey,
        child: Stack(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, top: 10),
                    child: CustomText(
                      text: "Edit Profile",
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 2,
                    padding: EdgeInsets.only(left: 20, right: 50),
                    child: Row(
                      children: [
                        Expanded(
                          child: EditFormTextField(
                            // hintText: user.firstName.toString(),
                            valid: (val) {
                              if (val!.isEmpty)
                                return "First Name Can'\t be Empty";
                              else
                                return null;
                            },
                            myController: _firstName,
                            text: 'First Name',
                            color: Theme.of(context).iconTheme.color,
                            fontsize: 20,
                            Fontweight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                            child: EditFormTextField(
                          // hintText: user.lastName,
                          valid: (val) {
                            if (val!.isEmpty)
                              return "Last Name Can'\t be Empty";
                            else
                              return null;
                          },
                          myController: _lastName,
                          text: 'Last Name',
                          color: Theme.of(context).iconTheme.color,
                          fontsize: 20,
                          Fontweight: FontWeight.bold,
                        )),
                        SizedBox(
                          width: 40,
                        ),
                        imageProfile(),
                      ],
                    ),
                  ),
                  Container(
                    // width: 300,
                    padding: EdgeInsets.only(left: 15, right: 50),
                    child: Row(
                      children: [
                        Expanded(
                            child: EditFormTextField(
                          // hintText: user.userType,
                          myController: _userType,
                          valid: (String? val) {
                            if (val!.isEmpty)
                              return "Title Name Can'\t be Empty";
                            else
                              return null;
                          },
                          text: 'Title Name',
                          color: Theme.of(context).iconTheme.color,
                          fontsize: 20,
                          Fontweight: FontWeight.bold,
                        )),
                        SizedBox(
                          width: 80,
                        ),
                        Spacer(flex: 1),
                        // imageProfile(),
                        InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => bottomSheet()),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                'Change Picture',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 50),
                    child: Row(
                      children: [
                        Expanded(
                            child: EditFormTextField(
                          // hintText: user.userType,
                          myController: _mobile,
                          valid: (String? val) {
                            if (val!.isEmpty)
                              return "Mobile Number Can'\t be Empty";
                            else
                              return null;
                          },
                          text: 'Mobile Number',
                          color: Theme.of(context).iconTheme.color,
                          fontsize: 20,
                          Fontweight: FontWeight.bold,
                        )),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: EditFormTextField(
                          // hintText: user.email,
                          myController: _email,
                          valid: (String? val) {
                            if (val!.isEmpty)
                              return "Email ID Can'\t be Empty";
                            else
                              return null;
                          },
                          text: 'Email ID',
                          color: Theme.of(context).iconTheme.color,
                          fontsize: 20,
                          Fontweight: FontWeight.bold,
                        )),
                        SizedBox(
                          width: 150,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 150,
                              width: 300.0,
                              child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextField(
                                      expands: true,
                                      controller: _biography,
                                      maxLines: null, //or null
                                      decoration:
                                          const InputDecoration.collapsed(
                                              hintText: "Enter your text here"),
                                    ),
                                  ))),
                        ),
                        const SizedBox(
                          width: 120.0,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                CustomText(
                                  text: 'Your Signature',
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
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
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (editProfileFormGlobalKey.currentState!
                                      .validate()) {
                                    editProfileFormGlobalKey.currentState!
                                        .save();
                                    // use the email provided here
                                    if (_imageFile != null) {
                                      final imageBase64 = base64.encode(
                                          File(_imageFile!.path)
                                              .readAsBytesSync());
                                      String imageName =
                                          _imageFile!.path.split("/").last;
                                      setState(() {
                                        _imageBase64 = imageBase64;
                                        _imageName = imageName;
                                      });
                                    }
                                    Map<String, dynamic> data = {
                                      'id': id.toString(),
                                      'first_name': _firstName.text.toString(),
                                      'last_name': _lastName.text.toString(),
                                      'email': _email.text.toString(),
                                      'user_type': _userType.text.toString(),
                                      'contact_number': _mobile.text.toString(),
                                      "biography": _biography.text.toString(),
                                      'profile_image': _imageName!,
                                      'imageSelf': _imageBase64!,
                                      "uploadSignature":
                                          base64.encode(signature!)
                                    };
                                    final Future<Map<String, dynamic>>
                                        response =
                                        authProvider.updateProfile(data);
                                    response.then((response) {
                                      if (response['status']) {
                                        User user = response['user'];
                                        Provider.of<UserProfilePageProvider>(context,
                                                listen: false)
                                            .setUser(user);
                                        Navigator.pushReplacementNamed(
                                            context, ProfileUser.routeName);
                                      } else {
                                        Flushbar(
                                          title: "Update Profile Failed",
                                          message:
                                              response['message'].toString(),
                                          duration: Duration(seconds: 6),
                                          backgroundColor: Colors.redAccent,
                                          titleColor: Colors.white,
                                          messageColor: Colors.white,
                                        ).show(context);
                                      }
                                    });
                                  } else {
                                    Flushbar(
                                      title: "Invalid Information's",
                                      message: "please insert correct details",
                                      duration: const Duration(seconds: 10),
                                    ).show(context);
                                  }
                                },
                                child: authProvider.loading
                                    ? CircularProgressIndicator(
                                        color: Colors.green,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 20),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: const Text(
                                              'Save Changes',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/profileUser');
                                            },
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        )),
                      ],
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

  Widget bottomSheet() {
    return Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Text('Choose an Photo', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              icon: Icon(
                Icons.camera,
                size: 24.0,
              ),
              label: Text('Camera'), // <-- Text
            ),
            SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              icon: Icon(
                Icons.image,
                size: 24.0,
              ),
              label: Text('Gallery'), // <-- Text
            ),
          ])
        ]));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.brown.shade800,
            radius: 70.0,
            backgroundImage: _imageFile == null ? AssetImage("assets/images/profile.jpg") as ImageProvider : FileImage(File(_imageFile!.path)),
          ),
          Positioned(
              child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => bottomSheet()),
                    );
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.teal,
                  )))
        ],
      ),
    );
  }

  Future<XFile?> takePhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });
  }

  Widget buildButton(BuildContext context) => Container(
        color: Colors.black,
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buildSave(context), buildClear()],
        ),
      );

  buildSave(BuildContext context) => IconButton(
      onPressed: () async {
        if (signController.isNotEmpty) {
          signature = await exportSignature();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignaturePerview(signature: signature!),
          ));
        }
      },
      icon: const Icon(
        Icons.save,
        color: Colors.green,
      ));

  buildClear() => IconButton(
      onPressed: () {
        signController.clear();
      },
      icon: const Icon(
        Icons.clear,
        color: Colors.green,
      ));

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: signController.points,
    );
    signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }
}
