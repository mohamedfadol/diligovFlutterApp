import 'package:diligov/widgets/custome_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'custom_icon.dart';

class DropdownStringList extends StatefulWidget {
  final String selectedValue;
  final List<String> dropdownItems;
  final Widget? hint;
  final ValueChanged<String?> onChanged;
  final Color color;
  final Color boxDecoration;
  const DropdownStringList({
    required this.hint,
    required this.selectedValue,
    required this.dropdownItems,
    required this.onChanged,
    required this.color,
    required this.boxDecoration
  });

  @override
  State<DropdownStringList> createState() => _DropdownStringListState();
}

class _DropdownStringListState extends State<DropdownStringList> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isExpanded: true,
      isDense: true,
      hint:  widget.hint,
      style: Theme.of(context).textTheme.titleLarge,
      buttonStyleData: ButtonStyleData(elevation: 2,
        decoration: BoxDecoration(color: widget.boxDecoration),
        height: 30,
      ),
      menuItemStyleData:  MenuItemStyleData(height: 40,),
      dropdownStyleData: DropdownStyleData(
          maxHeight: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),)
      ),
      value: widget.selectedValue,
      items: widget.dropdownItems.map((String value) {
        return DropdownMenuItem<String>(
          alignment: Alignment.center,
          // enabled: false,
          value: value.toString(),
          child: CustomText(text: value, color: widget.color),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }
}
