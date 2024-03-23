import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../models/user.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custome_text.dart';
class AnnualAuditReport extends StatefulWidget {
  const AnnualAuditReport({Key? key}) : super(key: key);
  static const routeName = '/AnnualAuditReport';

  @override
  State<AnnualAuditReport> createState() => _AnnualAuditReportState();
}

class _AnnualAuditReportState extends State<AnnualAuditReport> {

  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  bool isLoading = false;

  // Initial Selected Value
  String yearSelected = '2023';
  // List of items in our dropdown menu
  var yeasList = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
    '2032'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Column(
        children: [
          buildFullTopFilter(),
        ],
      ),
    );
  }


  Widget buildFullTopFilter() => Padding(
    padding:
    const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
    child: Row(
      children: [
        Container(
            padding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            color: Colors.red,
            child: CustomText(
                text: 'Annual Audit Report',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          width: 140,
          padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          color: Colors.red,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.headline6,
              hint: const Text("Select an Year",
                  style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.white60,
              focusColor: Colors.redAccent[300],
              // Initial Value
              value: yearSelected,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Colors.white),
              // Array list of items
              items: [
                const DropdownMenuItem(
                  value: "",
                  child: Text("Select an Year",
                      style: TextStyle(color: Colors.black)),
                ),
                ...yeasList!.map((item) {
                  return DropdownMenuItem(
                    value: item.toString(),
                    child: Text(item,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ],
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) async {
                yearSelected = newValue!.toString();
                setState(() {
                  yearSelected = newValue!;
                });
                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                user = User.fromJson(json.decode(prefs.getString("user")!));
                print(user.businessId);
                Map<String, dynamic> data = {
                  "dateYearRequest": yearSelected!,
                  "business_id": user.businessId
                };
                // EvaluationPageProvider providerGetResolutionsByDateYear =
                // Provider.of<EvaluationPageProvider>(context,
                //     listen: false);
                // Future.delayed(Duration.zero, () {
                //   providerGetResolutionsByDateYear
                //       .getListOfEvaluationsMember(data);
                // });
              },
            ),
          ),
        ),
      ],
    ),
  );
}
