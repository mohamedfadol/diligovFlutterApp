import 'package:flutter/material.dart';
class DynamicDropdownButton extends StatefulWidget {
  final List<dynamic> items;
  final Function(dynamic) onChanged;
  const DynamicDropdownButton({required this.items, required this.onChanged});

  @override
  State<DynamicDropdownButton> createState() => _DynamicDropdownButtonState();
}

class _DynamicDropdownButtonState extends State<DynamicDropdownButton> {
  dynamic _selectedItem;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<dynamic>(
      value: _selectedItem,
      onChanged: (dynamic? newValue) {
        setState(() {
          _selectedItem = newValue;
          widget.onChanged(newValue);
        });
      },
      items: widget.items.map<DropdownMenuItem<dynamic>>((dynamic item) {
        return DropdownMenuItem<dynamic>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
    );
  }
}
