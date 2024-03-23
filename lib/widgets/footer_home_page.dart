import 'package:diligov/widgets/custom_icon.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../colors.dart';
import '../models/user.dart';
import '../providers/authentications/user_provider.dart';
import '../providers/theme_provider.dart';
class FooterHomePage extends StatefulWidget {
  const FooterHomePage({super.key});

  @override
  State<FooterHomePage> createState() => _FooterHomePageState();
}

class _FooterHomePageState extends State<FooterHomePage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    User  user = Provider.of<UserProfilePageProvider>(context).user;
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(text: AppLocalizations.of(context)!.welcome + ' : ' ,fontSize: 15,fontWeight: FontWeight.bold,color: themeProvider.isDarkMode == true ? Colour().mainContentColor : Colour().iconsGreyColor,),
                SizedBox(width: 10.0,),
                CustomText(text: '${user.firstName.toString()}' '${user.lastName.toString()}' ,fontSize: 15,fontWeight: FontWeight.bold, color: themeProvider.isDarkMode == true ? Colour().mainContentColor : Colour().iconsGreyColor,),
              ],
            ),
            Row(
              children: [
                CustomText(text: AppLocalizations.of(context)!.connection_status + ' : ' ,fontSize: 15,fontWeight: FontWeight.bold,color: themeProvider.isDarkMode == true ? Colour().mainContentColor : Colour().iconsGreyColor,),
                SizedBox(width: 10.0,),
                CustomText(text: AppLocalizations.of(context)!.strong_encrypted ,fontSize: 15,fontWeight: FontWeight.bold, color: themeProvider.isDarkMode == true ? Colors.green : Colors.green,),
              ],
            )
          ],
        ),
        Container(
            padding: const EdgeInsets.only(right: 15,bottom: 0),
            child: CustomText(text: "${DateFormat.jm().format(DateTime.now())} - Riyadh - ${DateFormat("dd/MM/yyyy")
                .format(DateTime.now())}",fontSize: 15,fontWeight: FontWeight.bold)

        )

      ],
    );
  }
}
