import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/images_assets.dart';
import '../../models/user.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../providers/authentications/user_provider.dart';
import '../../widgets/assets_widgets/asset_general.dart';
import '../../widgets/assets_widgets/login_image.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/custome_text_form_field.dart';
import '../../widgets/drowpdown_list_languages_widget.dart';
import '../../widgets/menu_button.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class LoginScreen extends StatelessWidget with InputValidationMixin{
  final player = AudioPlayer();
  LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/loginPage';
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController(text: 'test@test.com');
  final TextEditingController _password = TextEditingController(text: 'test@test.com');
   
  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Form(
            key: formGlobalKey,
            child: Center(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const DropdownListLanguagesWidget(),
                        AssetGeneral(image: ImagesAssets.onOffButton,height: 40,width: 40,),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    alignment: Alignment.center, // This is needed
                    child: Image.asset(
                      ImagesAssets.loginLogo,
                      fit: BoxFit.contain,
                      width: 300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: CustomeTextFormField(
                        valid: (val){if (isEmailValid(val!) && val.isNotEmpty ) {return null;} else {return 'Enter a valid email address';}},
                        myController: _email,
                        hintText: "Enter Your E-mail",
                        prefixIcon: Icons.email,
                        suffixIcon: null,
                        borderRadius: 20,
                        lableText: "E-mail"),
                  ),
                  const SizedBox(height:25),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 150.0),
                     child: CustomeTextFormField(
                         valid: (val){
                           if (val == null ) {return 'Enter a valid password';} else {return null;}
                          },
                         obSecureText: true,
                         myController: _password,
                         hintText: "Enter Your Password",
                         prefixIcon: Icons.keyboard_alt_outlined,
                         suffixIcon: Icons.remove_red_eye_outlined,
                         borderRadius: 20,
                         lableText: "Password"
                     ),
                   ),
                  const SizedBox(height:25),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Material(
                      color: Colors.red,
                      elevation: 10,
                      borderRadius: BorderRadius.circular(30),
                      child: TextButton(
          
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (formGlobalKey.currentState!.validate()) {
                                formGlobalKey.currentState!.save();
                                // use the email provided here
                              final Future<Map<String,dynamic>> response =  authProvider.login(_email.text.toString(), _password.text.toString());
                              response.then((response) async{
                                if(response['status']){
                                  UserModel user = response['user'];
                                  Provider.of<UserProfilePageProvider>(context,listen: false).setUser(user.user);
                                  Navigator.pushReplacementNamed(context, '/dashboardHome');
                                  player.play(AssetSource('audio/play_login.mp3'));
                                }else{
                                  Flushbar(
                                    title: AppLocalizations.of(context)!.login_failed ,
                                    message: response['message'].toString(),
                                    duration: const Duration(seconds: 6),
                                    backgroundColor: Colors.redAccent,
                                    titleColor: Colors.white,
                                    messageColor: Colors.white,
                                  ).show(context);
                                }
                              });
          
                            }else{
                              Flushbar(
                                    title: AppLocalizations.of(context)!.invalid_information_login ,
                                    message: AppLocalizations.of(context)!.please_insert_correct_details,
                                    duration: const Duration(seconds: 10),
                              ).show(context);
                            }
          
                          },
                          child: authProvider.loading ? const CircularProgressIndicator(color: Colors.white,) : MenuButton(text: AppLocalizations.of(context)!.login,fontSize: 20.0,fontWeight: FontWeight.bold,),
                    ),
                    ),
                  ),
                  // LanguageWidget(),
                  // DropdownListLanguagesWidget(),
                  const SizedBox(height:25),
                  Center(
                    // margin: const EdgeInsets.symmetric(horizontal: 570),
                    child: InkWell(
                      onTap: (){},
                      child: CustomText(text: AppLocalizations.of(context)!.forget_password,fontSize: 15,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

mixin InputValidationMixin {
  bool isPasswordValid(String val) => val.length == 6;

  bool isEmailValid(String val) {
    final RegExp regex =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    return regex.hasMatch(val);
  }
}


