import 'package:diligov/widgets/assets_widgets/asset_general.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/images_assets.dart';
import '../l10n/l10n.dart';
import '../providers/localizations_provider.dart';
class DropdownListLanguagesWidget extends StatelessWidget {
  const DropdownListLanguagesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerLanguage = Provider.of<LocalizationsProvider>(context);
    final locale = providerLanguage.locale;
    return DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: AssetGeneral(image: ImagesAssets.languageLogo,height: 40,width:40,),
          value: locale,
          icon: Container(width: 10,),
          items: L10n.all.map((locale){
            final flag = L10n.getFlag(locale.languageCode);
            return DropdownMenuItem(
                child: Center(
                  child: CustomText(text:flag,fontSize: 30.0),
                ),
              value: locale,
              onTap: (){
                final localeLanguage = Provider.of<LocalizationsProvider>(context,listen: false);
                localeLanguage.setLocale(locale);
              },
            );
          }
          ).toList(),
          onChanged: (_){

          },
        )
    );
  }
}
