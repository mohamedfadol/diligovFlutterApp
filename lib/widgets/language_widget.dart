import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
class LanguageWidget extends StatelessWidget {
  const LanguageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final  local = Localizations.localeOf(context);
    final flag = L10n.getFlag(local.languageCode);
    return Center(
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: CustomText(text:flag,fontSize: 50.0),
      )
    );
  }
}
